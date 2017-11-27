Library ieee;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE ieee.std_logic_unsigned.All;
USE WORK.CANconstants.ALL;
use work.CANcomponents.ALL;

-------------------------------------------------------------------------------------------------------------
--
-- CAN with Flexible Data-Rate IP Core 
--
-- Copyright (C) 2015 Ondrej Ille <ondrej.ille@gmail.com>
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- The CAN protocol is developed by Robert Bosch GmbH and     
-- protected by patents. Anybody who wants to implement this    
-- IP core on silicon has to obtain a CAN protocol license
-- from Bosch.
--
--
-- Revision History:
--
--    July 2015   Created file
--    22.6.2016   1. Added rec_esi signal for error state propagation into the RX buffer.
--                2. Added explicit architecture selection for each component (RTL)
--    24.8.2016   Added "use_logger" generic to the registers module.
--    28.11.2017  Added "rst_sync_comp" reset synchroniser. 
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Purpose:
--  Enity encapsulating all functionality of CAN FD node.
--  Instances:
--      1x Memory registers
--      1x Interrupt manager
--      1x Prescaler (v3)
--      1x Bus synchronizes
--      1x Event Logger
--      1x Rx buffer
--      2x TXT buffer
--      1x Tx Arbitrator
--      1x Acceptance filters
------------------------------------------------------------

entity CAN_top_level is
  generic(
      constant use_logger     :     boolean  :=true; --Whenever event logger should be synthetised
      constant rx_buffer_size :     natural range 4 to 512 :=128; --Transcieve Buffer size
      constant useFDSize      :     boolean  :=true; --Transcieve buffer size should be synthetised as FD Size (640 bits) or normal CAN (128 bits)
      constant use_sync       :     boolean  :=true; --Whenever internal synchroniser chain should be used for incoming bus signals
                                                --Dont turn off unless external synchronisation chain is put on input of FPGA by
                                                --synthetiser
      constant ID             :     natural  range 0 to 15:=1; --ID (bits  19-16 of adress) 
      constant logger_size    :     natural --range 0 to 512:=8
  );
  port(
      --------------------------
      --System clock and reset--
      --------------------------
      signal clk_sys          :in   std_logic;
      signal res_n            :in   std_logic;
      
      ---------------------
      --Memory interface --
      ---------------------
      signal data_in          :in   std_logic_vector(31 downto 0);
      signal data_out         :out  std_logic_vector(31 downto 0);
      signal adress           :in   std_logic_vector(23 downto 0);
    	 signal scs              :in   std_logic; --Chip select
      signal srd              :in   std_logic; --Serial read
      signal swr              :in   std_logic; --Serial write
      --Note: This bus is Avalon compatible!
      
      --------------------
      --Interrupt output--
      --------------------
      signal int              :out  std_logic;
      
      -------------------
      --CAN Bus output --
      -------------------
      signal CAN_tx           :out  std_logic;
      signal CAN_rx           :in   std_logic;
      
      ---------------------------
      --Synchronisation signals--
      ---------------------------
      signal time_quanta_clk  :out  std_logic; --Time Quantum clocks possible to be used for synchronisation
      
      -------------------------------------------
      --Timestamp value for time based messages--
      -------------------------------------------
      signal timestamp        :in   std_logic_vector(63 downto 0)
  );
  
  ---------------------
  --Internal signals --
  ---------------------
  signal res_n_int            :     std_logic;  -- Overal reset (External+Reset by memory access)
  signal res_n_sync           :     std_logic;  -- Synchronised reset
  
  signal drv_bus              :     std_logic_vector(1023 downto 0);
  signal stat_bus             :     std_logic_vector(511 downto 0);
  signal int_vector           :     std_logic_vector(10 downto 0); --Interrupt vector (Interrupt register of SJA1000)
  
  --Registers <--> RX Buffer Interface
  signal rx_read_buff         :     std_logic_vector(31 downto 0); --Actually loaded data for reading
  signal rx_buf_size          :     std_logic_vector(7 downto 0); --Actual size of synthetised message buffer (in 32 bit words)
  signal rx_full              :     std_logic; --Signal whenever buffer is full
  signal rx_empty             :     std_logic; --Signal whenever buffer is empty
  signal rx_message_count     :     std_logic_vector(7 downto 0); --Number of messaged stored in recieve buffer
  signal rx_mem_free          :     std_logic_vector(7 downto 0); --Number of free 32 bit wide ''windows''
  signal rx_read_pointer_pos  :     std_logic_vector(7 downto 0); --Position of read pointer
  signal rx_write_pointer_pos :     std_logic_vector(7 downto 0); --Position of write pointer
  signal rx_message_disc      :     std_logic; --Message was discarded since Memory is full
  signal rx_data_overrun      :     std_logic; --Some data were discarded, register  
  
  --Registers <--> TX Buffer, TXT Buffer
  signal tran_data_in         :     std_logic_vector(639 downto 0);  --Transcieve data (Common for TX Buffer and TXT Buffer)  
  signal txt1_disc            :     std_logic; --Info that message store into buffer from driving registers failed because buffer is full
  signal txt2_disc            :     std_logic; --Info that message store into buffer from driving registers failed because buffer is full 
  
  --Registers <--> event logger
  signal loger_act_data       :     std_logic_vector(63 downto 0);
  signal log_write_pointer    :     std_logic_vector(7 downto 0);
  signal log_read_pointer     :     std_logic_vector(7 downto 0);
  signal log_size             :     std_logic_vector(7 downto 0);
  signal log_state_out        :     logger_state_type;
    
  --TX Arbitrator <--> TX Buffer, TXT Buffer
  signal txt1_buffer_in       :     std_logic_vector(639 downto 0); --Time TX buffer input
  signal txt1_buffer_ack      :     std_logic; --Time buffer acknowledge that message can be erased
  signal txt1_buffer_empty    :     std_logic; --No message in Time TX Buffer
  signal txt2_buffer_in       :     std_logic_vector(639 downto 0); --Time TX buffer input
  signal txt2_buffer_ack      :     std_logic; --Time buffer acknowledge that message can be erased
  signal txt2_buffer_empty    :     std_logic; --No message in Time TX Buffer
  
  --TX Arbitrator <--> CAN Core
  signal tran_data_out        :     std_logic_vector(511 downto 0); --TX Message data
  signal tran_ident_out       :     std_logic_vector(28 downto 0); --TX Identifier 
  signal tran_dlc_out         :     std_logic_vector(3 downto 0); --TX Data length code
  signal tran_is_rtr          :     std_logic; --TX is remote frame
  signal tran_ident_type_out  :     std_logic; --TX Identifier type (0-Basic,1-Extended);
  signal tran_frame_type_out  :     std_logic; --TX Frame type
  signal tran_brs_out         :     std_logic; --Bit rate shift for CAN FD frames
  signal tran_frame_valid_out :     std_logic; --Signal for CAN Core that frame on the output is valid and can be stored for transmitting
  signal tran_data_ack        :     std_logic; --Acknowledge from CAN core that acutal message was stored into internal buffer for transmitting
  
  --RX Buffer <--> CAN Core
  signal rec_ident_in         :     std_logic_vector(28 downto 0); --Message Identifier
  signal rec_data_in          :     std_logic_vector(511 downto 0); --Message Data (up to 64 bytes);
  signal rec_dlc_in           :     std_logic_vector(3 downto 0); --Data length code
  signal rec_ident_type_in    :     std_logic; --Recieved identifier type (0-BASE Format, 1-Extended Format);
  signal rec_frame_type_in    :     std_logic; --Recieved frame type (0-Normal CAN, 1- CAN FD)
  signal rec_is_rtr           :     std_logic; --Recieved frame is RTR Frame(0-No, 1-Yes)
  signal rec_message_valid    :     std_logic; 
  signal rec_brs              :     std_logic; --Whenever frame was recieved with BIT Rate shift 
  signal rec_message_ack      :     std_logic; --Acknowledge for CAN Core about accepted data
  signal rec_esi              :     std_logic;
  
  --RX Buffer <--> Message filters
  signal out_ident_valid      :     std_logic; --Signal whenever identifier matches the filter identifiers
  
  --Interrupt manager <--> CAN Core
  signal error_valid          :     std_logic; --Valid Error appeared for interrupt
  signal error_passive_changed:     std_logic; --Error pasive /Error acitve functionality changed
  signal error_warning_limit  :     std_logic; --Error warning limit reached
  signal arbitration_lost     :     std_logic; --Arbitration was lost input
  signal wake_up_valid        :     std_logic; --Wake up appeared
  signal tx_finished          :     std_logic; --Message stored in CAN Core was sucessfully transmitted
  signal br_shifted           :     std_logic; --Bit Rate Was Shifted
  
  signal loger_finished       :     std_logic;  --Event logging finsihed  
  --Prescaler <--> CAN Core 
  signal sync_edge            :     std_logic; --Edge for synchronisation
  signal OP_State             :     oper_mode_type; --Protocol control state
    
  signal clk_tq_nbt           :     std_logic; --Time quantum clock - Nominal bit time
  signal clk_tq_dbt           :     std_logic; --bit time - Nominal bit time
    
  signal sample_nbt           :     std_logic; --Sample signal for nominal bit time
  signal sample_dbt           :     std_logic; --Sample signal of data bit time
  signal sample_nbt_del_1     :     std_logic;
  signal sample_dbt_del_1     :     std_logic;
  signal sample_nbt_del_2     :     std_logic;
  signal sample_dbt_del_2     :     std_logic;
    
  signal sync_nbt             :     std_logic;
  signal sync_dbt             :     std_logic;
  signal sync_nbt_del_1       :     std_logic;
  signal sync_dbt_del_1       :     std_logic;

  signal sp_control           :     std_logic_vector(1 downto 0);
  signal sync_control         :     std_logic_vector(1 downto 0);
  
  signal bt_FSM_out           :     bit_time_type;
  
  signal hard_sync_edge_valid :     std_logic; --Validated hard synchronisation edge to start Protocol control FSM
          --Note: Sync edge from busSync.vhd cant be used! If it comes during sample nbt, sequence it causes
          --      errors! It needs to be strictly before or strictly after this sequence!!! 
  
  --Bus Synchroniser
  signal data_tx              :     std_logic; --Transcieve data value
  signal data_rx              :     std_logic; --Recieved data value
  signal ssp_reset            :     std_logic; --Clear the Shift register at the  beginning of Data Phase!!!
  signal trv_delay_calib      :     std_logic; --Calibration command for transciever delay compenstation (counter)
  signal bit_Error_sec_sam    :     std_logic; --Bit error with secondary sampling transciever!
    
  signal sample_sec           :     std_logic; --Secondary sample signal 
  signal sample_sec_del_1     :     std_logic; --Bit destuffing trigger for secondary sample point
  signal sample_sec_del_2     :     std_logic; --Rec trig for secondary sample point
  
  signal trv_delay_out        :     std_logic_vector(15 downto 0);
   
end entity CAN_top_level;
   
architecture rtl of CAN_top_level is

  ----------------------------------------------------
  --Defining explicit architectures for used entites
  ----------------------------------------------------
    for reg_comp        : registers     use entity work.registers(rtl);
    for rx_buf_comp     : rxBuffer      use entity work.rxBuffer(rtl);
    for txt1_buf_comp   : txtBuffer     use entity work.txtBuffer(rtl);
    for txt2_buf_comp   : txtBuffer     use entity work.txtBuffer(rtl);
    for tx_arb_comp     : txArbitrator  use entity work.txArbitrator(rtl);
    for mes_filt_comp   : messageFilter use entity work.messageFilter(rtl);
    for int_man_comp    : intManager    use entity work.intManager(rtl); 
    for core_top_comp   : core_top      use entity work.core_top(rtl); 
    for prescaler_comp  : prescaler_v3  use entity work.prescaler_v3(rtl); 
    for bus_sync_comp   : busSync       use entity work.busSync(rtl);
    for rst_sync_comp   : rst_sync      use entity work.rst_sync(rtl);
    --for log_comp : CAN_logger use entity work.CAN_logger(rtl);

begin
  
  rst_sync_comp:rst_sync
  port map(
       clk                =>  clk_sys,
       arst_n             =>  res_n,
       rst_n              =>  res_n_sync
  );
  
  reg_comp:registers
  generic map(
     compType             =>  CAN_COMPONENT_TYPE,
     use_logger           =>  use_logger,
     ID                   =>  ID
  )
  port map(
     clk_sys              =>  clk_sys,
     res_n                =>  res_n_sync,
     res_out              =>  res_n_int,
     data_in              =>  data_in,
     data_out             =>  data_out,
     adress               =>  adress,
     scs                  =>  scs,
     srd                  =>  srd,
     swr                  =>  swr,
     drv_bus              =>  drv_bus,
     stat_bus             =>  stat_bus, 
     rx_read_buff         =>  rx_read_buff,
     rx_buf_size          =>  rx_buf_size,
     rx_full              =>  rx_full,
     rx_empty             =>  rx_empty,
     rx_message_count     =>  rx_message_count,
     rx_mem_free          =>  rx_mem_free,
     rx_read_pointer_pos  =>  rx_read_pointer_pos,
     rx_write_pointer_pos =>  rx_write_pointer_pos,
     rx_message_disc      =>  rx_message_disc,
     rx_data_overrun      =>  rx_data_overrun,
     tran_data_in         =>  tran_data_in,
     txt2_empty           =>  txt2_buffer_empty,
     txt2_disc            =>  txt2_disc,
     txt1_empty           =>  txt1_buffer_empty,
     txt1_disc            =>  txt1_disc,
     int_vector           =>  int_vector,
     trv_delay_out        =>  trv_delay_out,
     loger_act_data       =>  loger_act_data,
     log_write_pointer    =>  log_write_pointer,
     log_read_pointer     =>  log_read_pointer,
     log_size             =>  log_size,
     log_state_out        =>  log_state_out
  );
  
  rx_buf_comp:rxBuffer
  generic map(
      buff_size           =>  rx_buffer_size
  )
  port map(
     clk_sys              =>  clk_sys,
     res_n                =>  res_n_int,
     rec_ident_in         =>  rec_ident_in,
     rec_data_in          =>  rec_data_in,
     rec_dlc_in           =>  rec_dlc_in,
     rec_ident_type_in    =>  rec_ident_type_in,
     rec_frame_type_in    =>  rec_frame_type_in,
     rec_is_rtr           =>  rec_is_rtr,
     rec_message_valid    =>  out_ident_valid, --Note: This has to be confirmed from Message filters not CAN Core
     rec_brs              =>  rec_brs,
     rec_esi              =>  rec_esi,
     rec_message_ack      =>  rec_message_ack,
     rx_buf_size          =>  rx_buf_size,
     rx_full              =>  rx_full,
     rx_empty             =>  rx_empty,
     rx_message_count     =>  rx_message_count,
     rx_mem_free          =>  rx_mem_free,
     rx_read_pointer_pos  =>  rx_read_pointer_pos,
     rx_write_pointer_pos =>  rx_write_pointer_pos,
     rx_message_disc      =>  rx_message_disc,
     rx_data_overrun      =>  rx_data_overrun,
     rx_read_buff         =>  rx_read_buff,
     timestamp            =>  timestamp,
     drv_bus              =>  drv_bus
  );
  
  txt1_buf_comp:txtBuffer
    generic map(
        ID                =>  1,
        useFDsize         =>  useFDsize
    ) 
    PORT map(
       clk_sys            =>  clk_sys,
       res_n              =>  res_n_int,
       drv_bus            =>  drv_bus,
       tran_data_in       =>  tran_data_in,
       
       txt_empty          =>  txt1_buffer_empty,
       txt_disc           =>  txt1_disc,
       txt_buffer_out     =>  txt1_buffer_in,
       txt_data_ack       =>  txt1_buffer_ack
      );  

  txt2_buf_comp:txtBuffer
    generic map(
        ID                =>  2,
        useFDsize         =>  useFDsize
    )  
    PORT map(
       clk_sys            =>  clk_sys,
       res_n              =>  res_n_int,
       drv_bus            =>  drv_bus,
       tran_data_in       =>  tran_data_in,
       
       txt_empty          =>  txt2_buffer_empty,
       txt_disc           =>  txt2_disc,
       txt_buffer_out     =>  txt2_buffer_in,
       txt_data_ack       =>  txt2_buffer_ack
      );                
  
  tx_arb_comp:txArbitrator
  port map( 
     txt1_buffer_in       =>  txt1_buffer_in,
     txt1_buffer_ack      =>  txt1_buffer_ack,
     txt1_buffer_empty    =>  txt1_buffer_empty,
     txt2_buffer_in       =>  txt2_buffer_in,
     txt2_buffer_empty    =>  txt2_buffer_empty,
     txt2_buffer_ack      =>  txt2_buffer_ack,
     tran_data_out        =>  tran_data_out,
     tran_ident_out       =>  tran_ident_out,
     tran_dlc_out         =>  tran_dlc_out,
     tran_is_rtr          =>  tran_is_rtr,
     tran_ident_type_out  =>  tran_ident_type_out,
     tran_frame_type_out  =>  tran_frame_type_out,
     tran_brs_out         =>  tran_brs_out,
     tran_frame_valid_out =>  tran_frame_valid_out,
     tran_data_ack        =>  tran_data_ack,
     drv_bus              =>  drv_bus,
     timestamp            =>  timestamp
  );
  
 mes_filt_comp:messageFilter
  port map(
     clk_sys              =>  clk_sys,
     res_n                =>  res_n,
     rec_ident_in         =>  rec_ident_in,
     ident_type           =>  rec_ident_type_in,
     frame_type           =>  rec_frame_type_in,
     rec_ident_valid      =>  rec_message_valid,
     drv_bus              =>  drv_bus,
     out_ident_valid      =>  out_ident_valid
    );
  
  int_man_comp:intManager
  generic map(
    int_length            =>  7
    )
  port map(
     clk_sys              =>  clk_sys,
     res_n                =>  res_n_int,
     error_valid          =>  error_valid,
     error_passive_changed=>  error_passive_changed,
     error_warning_limit  =>  error_warning_limit,
     arbitration_lost     =>  arbitration_lost,
     wake_up_valid        =>  wake_up_valid,
     tx_finished          =>  tx_finished,
     br_shifted           =>  br_shifted,
     rx_message_disc      =>  rx_message_disc,
     rec_message_valid    =>  rec_message_valid,
     rx_full              =>  rx_full,
     loger_finished       =>  loger_finished,
     drv_bus              =>  drv_bus,
     int_out              =>  int,
     int_vector           =>  int_vector
  );
  
  core_top_comp: core_top
  port map(
     clk_sys              =>  clk_sys,
     res_n                =>  res_n_int,
     drv_bus              =>  drv_bus,
     stat_bus             =>  stat_bus ,
     tran_data_in         =>  tran_data_out,
     tran_ident_in        =>  tran_ident_out,
     tran_dlc_in          =>  tran_dlc_out,
     tran_is_rtr_in       =>  tran_is_rtr,
     tran_ident_type_in   =>  tran_ident_type_out,
     tran_frame_type_in   =>  tran_frame_type_out,
     tran_brs_in          =>  tran_brs_out,
     tran_frame_valid_in  =>  tran_frame_valid_out,
     tran_data_ack_out    =>  tran_data_ack,
     rec_ident_out        =>  rec_ident_in,
     rec_data_out         =>  rec_data_in,
     rec_dlc_out          =>  rec_dlc_in,
     rec_ident_type_out   =>  rec_ident_type_in,
     rec_frame_type_out   =>  rec_frame_type_in,
     rec_is_rtr_out       =>  rec_is_rtr,
     rec_brs_out          =>  rec_brs,
     rec_esi_out          =>  rec_esi,
     rec_message_valid_out=>  rec_message_valid,
     rec_message_ack_out  =>  rec_message_ack,
     arbitration_lost_out =>  arbitration_lost,
     wake_up_valid        =>  wake_up_valid,
     tx_finished          =>  tx_finished,
     br_shifted           =>  br_shifted,
     error_valid          =>  error_valid,
     error_passive_changed=>  error_passive_changed,
     error_warning_limit  =>  error_warning_limit,
     sample_nbt_del_2     =>  sample_nbt_del_2,
     sample_dbt_del_2     =>  sample_dbt_del_2,
     sample_nbt_del_1     =>  sample_nbt_del_1,
     sample_dbt_del_1     =>  sample_dbt_del_1,
     sync_nbt             =>  sync_nbt,
     sync_dbt             =>  sync_dbt,
     sync_nbt_del_1       =>  sync_nbt_del_1,
     sync_dbt_del_1       =>  sync_dbt_del_1,
     sample_sec           =>  sample_sec,
     sample_sec_del_1     =>  sample_sec_del_1,
     sample_sec_del_2     =>  sample_sec_del_2 ,    
     sync_control         =>  sync_control,
     data_rx              =>  data_rx,
     data_tx              =>  data_tx,
     timestamp            =>  timestamp,
     sp_control           =>  sp_control,
     ssp_reset            =>  ssp_reset,
     trv_delay_calib      =>  trv_delay_calib,
     hard_sync_edge       =>  hard_sync_edge_valid,
     bit_Error_sec_sam    =>  bit_Error_sec_sam
   );
  
  prescaler_comp:prescaler_v3
  port map(
     clk_sys              =>  clk_sys,
     res_n                =>  res_n,
     OP_State             =>  OP_State,
     sync_edge            =>  sync_edge,
     drv_bus              =>  drv_bus ,
     clk_tq_nbt           =>  clk_tq_nbt,
     clk_tq_dbt           =>  clk_tq_dbt  ,
     sample_nbt           =>  sample_nbt,
     sample_dbt           =>  sample_dbt,
     bt_FSM_out           =>  bt_FSM_out,
     sample_nbt_del_1     =>  sample_nbt_del_1,
     sample_dbt_del_1     =>  sample_dbt_del_1,
     sample_nbt_del_2     =>  sample_nbt_del_2,
     sample_dbt_del_2     =>  sample_dbt_del_2,
     sync_nbt             =>  sync_nbt,
     sync_dbt             =>  sync_dbt,
     sync_nbt_del_1       =>  sync_nbt_del_1,
     sync_dbt_del_1       =>  sync_dbt_del_1,
     data_tx              =>  data_tx,
     hard_sync_edge_valid =>  hard_sync_edge_valid,
     sp_control           =>  sp_control,
     sync_control         =>  sync_control
  );
  
  bus_sync_comp:busSync
  generic map (
      use_Sync            =>  use_sync
    )
  port map(
     clk_sys              =>  clk_sys,
     res_n                =>  res_n_int,
     CAN_rx               =>  CAN_rx,
     CAN_tx               =>  CAN_tx,
     drv_bus              =>  drv_bus,
     sample_nbt           =>  sample_nbt,
     sample_dbt           =>  sample_dbt,
     sync_edge            =>  sync_edge,
     data_tx              =>  data_tx,
     data_rx              =>  data_rx,
     sp_control           =>  sp_control,
     ssp_reset            =>  ssp_reset,
     trv_delay_calib      =>  trv_delay_calib,
     bit_err_enable       =>  '1', --Note: Bit Error detection enabled always. bit_Error signal from this block used only for secondary sample point bit error detection!!
     sample_sec_out       =>  sample_sec,
     sample_sec_del_1_out =>  sample_sec_del_1,
     sample_sec_del_2_out =>  sample_sec_del_2,
     trv_delay_out        =>  trv_delay_out,
     bit_Error            =>  bit_Error_sec_sam
   );
 
   
 LOG_GEN:if(use_logger=true) generate 
   log_comp:CAN_logger
  generic map(
     memory_size          =>  logger_size
  )
  port map(
     clk_sys              =>  clk_sys,
     res_n                =>  res_n,
    
     drv_bus              =>  drv_bus,
     stat_bus             =>  stat_bus,
     sync_edge            =>  sync_edge,
     timestamp            =>  timestamp,
    
     loger_finished       =>  loger_finished,
     loger_act_data       =>  loger_act_data,
     log_write_pointer    =>  log_write_pointer,
     log_read_pointer     =>  log_read_pointer,
     log_size             =>  log_size,
     log_state_out        =>  log_state_out,
     bt_FSM               =>  bt_FSM_out,
    data_overrun          =>  rx_data_overrun
  );
 end generate LOG_GEN;
 
 LOG_GEN2:if(use_logger=false)generate
    loger_finished        <=  '0';
    loger_act_data        <=  (OTHERS =>'0');
    log_write_pointer     <=  (OTHERS =>'0');
    log_read_pointer      <=  (OTHERS =>'0');
    log_size              <=  (OTHERS =>'0');
 end generate LOG_GEN2;
  
  --Bit time clock output propagation
  time_quanta_clk         <=  clk_tq_nbt when sp_control=NOMINAL_SAMPLE else clk_tq_dbt; 

  
  OP_State                <=  oper_mode_type'VAL(to_integer(unsigned(stat_bus(STAT_OP_STATE_HIGH downto STAT_OP_STATE_LOW))));
  
end architecture;