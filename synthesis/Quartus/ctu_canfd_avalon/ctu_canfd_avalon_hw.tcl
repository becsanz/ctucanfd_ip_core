# TCL File Generated by Component Editor 18.1
# Sat Sep 28 23:04:31 CEST 2019
# DO NOT MODIFY


# 
# ctu_canfd_avalon "ctu_canfd_avalon" v1.0
#  2019.09.28.23:04:31
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module ctu_canfd_avalon
# 
set_module_property DESCRIPTION ""
set_module_property NAME ctu_canfd_avalon
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME ctu_canfd_avalon
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL can_top_level
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file access_signaler.vhd VHDL PATH src/access_signaler.vhd
add_fileset_file address_decoder.vhd VHDL PATH src/address_decoder.vhd
add_fileset_file bit_destuffing.vhd VHDL PATH src/bit_destuffing.vhd
add_fileset_file bit_err_detector.vhd VHDL PATH src/bit_err_detector.vhd
add_fileset_file bit_filter.vhd VHDL PATH src/bit_filter.vhd
add_fileset_file bit_segment_meter.vhd VHDL PATH src/bit_segment_meter.vhd
add_fileset_file bit_stuffing.vhd VHDL PATH src/bit_stuffing.vhd
add_fileset_file bit_time_cfg_capture.vhd VHDL PATH src/bit_time_cfg_capture.vhd
add_fileset_file bit_time_counters.vhd VHDL PATH src/bit_time_counters.vhd
add_fileset_file bit_time_fsm.vhd VHDL PATH src/bit_time_fsm.vhd
add_fileset_file bus_sampling.vhd VHDL PATH src/bus_sampling.vhd
add_fileset_file bus_traffic_counters.vhd VHDL PATH src/bus_traffic_counters.vhd
add_fileset_file can_components.vhd VHDL PATH src/can_components.vhd
add_fileset_file can_config.vhd VHDL PATH src/can_config.vhd
add_fileset_file can_constants.vhd VHDL PATH src/can_constants.vhd
add_fileset_file can_core.vhd VHDL PATH src/can_core.vhd
add_fileset_file can_crc.vhd VHDL PATH src/can_crc.vhd
add_fileset_file can_fd_frame_format.vhd VHDL PATH src/can_fd_frame_format.vhd
add_fileset_file can_fd_register_map.vhd VHDL PATH src/can_fd_register_map.vhd
add_fileset_file can_registers_pkg.vhd VHDL PATH src/can_registers_pkg.vhd
add_fileset_file can_top_level.vhd VHDL PATH src/can_top_level.vhd TOP_LEVEL_FILE
add_fileset_file can_types.vhd VHDL PATH src/can_types.vhd
add_fileset_file cmn_lib.vhd VHDL PATH src/cmn_lib.vhd
add_fileset_file cmn_reg_map_pkg.vhd VHDL PATH src/cmn_reg_map_pkg.vhd
add_fileset_file control_counter.vhd VHDL PATH src/control_counter.vhd
add_fileset_file control_registers_reg_map.vhd VHDL PATH src/control_registers_reg_map.vhd
add_fileset_file crc_calc.vhd VHDL PATH src/crc_calc.vhd
add_fileset_file data_edge_detector.vhd VHDL PATH src/data_edge_detector.vhd
add_fileset_file data_mux.vhd VHDL PATH src/data_mux.vhd
add_fileset_file dff.vhd VHDL PATH src/dff.vhd
add_fileset_file dff_arst.vhd VHDL PATH src/dff_arst.vhd
add_fileset_file dff_arst_ce.vhd VHDL PATH src/dff_arst_ce.vhd
add_fileset_file dlc_decoder.vhd VHDL PATH src/dlc_decoder.vhd
add_fileset_file drv_stat_pkg.vhd VHDL PATH src/drv_stat_pkg.vhd
add_fileset_file endian_swapper.vhd VHDL PATH src/endian_swapper.vhd
add_fileset_file err_counters.vhd VHDL PATH src/err_counters.vhd
add_fileset_file err_detector.vhd VHDL PATH src/err_detector.vhd
add_fileset_file fault_confinement.vhd VHDL PATH src/fault_confinement.vhd
add_fileset_file fault_confinement_fsm.vhd VHDL PATH src/fault_confinement_fsm.vhd
add_fileset_file fault_confinement_rules.vhd VHDL PATH src/fault_confinement_rules.vhd
add_fileset_file frame_filters.vhd VHDL PATH src/frame_filters.vhd
add_fileset_file id_transfer.vhd VHDL PATH src/id_transfer.vhd
add_fileset_file inf_ram_wrapper.vhd VHDL PATH src/inf_ram_wrapper.vhd
add_fileset_file int_manager.vhd VHDL PATH src/int_manager.vhd
add_fileset_file int_module.vhd VHDL PATH src/int_module.vhd
add_fileset_file majority_decoder_3.vhd VHDL PATH src/majority_decoder_3.vhd
add_fileset_file memory_bus.vhd VHDL PATH src/memory_bus.vhd
add_fileset_file memory_reg.vhd VHDL PATH src/memory_reg.vhd
add_fileset_file memory_registers.vhd VHDL PATH src/memory_registers.vhd
add_fileset_file operation_control.vhd VHDL PATH src/operation_control.vhd
add_fileset_file prescaler.vhd VHDL PATH src/prescaler.vhd
add_fileset_file priority_decoder.vhd VHDL PATH src/priority_decoder.vhd
add_fileset_file protocol_control.vhd VHDL PATH src/protocol_control.vhd
add_fileset_file protocol_control_fsm.vhd VHDL PATH src/protocol_control_fsm.vhd
add_fileset_file range_filter.vhd VHDL PATH src/range_filter.vhd
add_fileset_file reduce_lib.vhd VHDL PATH src/reduce_lib.vhd
add_fileset_file reintegration_counter.vhd VHDL PATH src/reintegration_counter.vhd
add_fileset_file retransmitt_counter.vhd VHDL PATH src/retransmitt_counter.vhd
add_fileset_file rst_sync.vhd VHDL PATH src/rst_sync.vhd
add_fileset_file rx_buffer.vhd VHDL PATH src/rx_buffer.vhd
add_fileset_file rx_buffer_fsm.vhd VHDL PATH src/rx_buffer_fsm.vhd
add_fileset_file rx_buffer_pointers.vhd VHDL PATH src/rx_buffer_pointers.vhd
add_fileset_file rx_buffer_ram.vhd VHDL PATH src/rx_buffer_ram.vhd
add_fileset_file rx_shift_reg.vhd VHDL PATH src/rx_shift_reg.vhd
add_fileset_file sample_mux.vhd VHDL PATH src/sample_mux.vhd
add_fileset_file segment_end_detector.vhd VHDL PATH src/segment_end_detector.vhd
add_fileset_file shift_reg.vhd VHDL PATH src/shift_reg.vhd
add_fileset_file shift_reg_byte.vhd VHDL PATH src/shift_reg_byte.vhd
add_fileset_file shift_reg_preload.vhd VHDL PATH src/shift_reg_preload.vhd
add_fileset_file sig_sync.vhd VHDL PATH src/sig_sync.vhd
add_fileset_file synchronisation_checker.vhd VHDL PATH src/synchronisation_checker.vhd
add_fileset_file trigger_generator.vhd VHDL PATH src/trigger_generator.vhd
add_fileset_file trigger_mux.vhd VHDL PATH src/trigger_mux.vhd
add_fileset_file trv_delay_meas.vhd VHDL PATH src/trv_delay_meas.vhd
add_fileset_file tx_arbitrator.vhd VHDL PATH src/tx_arbitrator.vhd
add_fileset_file tx_arbitrator_fsm.vhd VHDL PATH src/tx_arbitrator_fsm.vhd
add_fileset_file tx_data_cache.vhd VHDL PATH src/tx_data_cache.vhd
add_fileset_file tx_shift_reg.vhd VHDL PATH src/tx_shift_reg.vhd
add_fileset_file txt_buffer.vhd VHDL PATH src/txt_buffer.vhd
add_fileset_file txt_buffer_fsm.vhd VHDL PATH src/txt_buffer_fsm.vhd
add_fileset_file txt_buffer_ram.vhd VHDL PATH src/txt_buffer_ram.vhd


# 
# parameters
# 
add_parameter rx_buffer_size INTEGER 128
set_parameter_property rx_buffer_size DEFAULT_VALUE 128
set_parameter_property rx_buffer_size DISPLAY_NAME rx_buffer_size
set_parameter_property rx_buffer_size TYPE INTEGER
set_parameter_property rx_buffer_size UNITS None
set_parameter_property rx_buffer_size ALLOWED_RANGES -2147483648:2147483647
set_parameter_property rx_buffer_size HDL_PARAMETER true
add_parameter ID INTEGER 1
set_parameter_property ID DEFAULT_VALUE 1
set_parameter_property ID DISPLAY_NAME ID
set_parameter_property ID TYPE INTEGER
set_parameter_property ID UNITS None
set_parameter_property ID ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ID HDL_PARAMETER true
add_parameter sup_filtA BOOLEAN true
set_parameter_property sup_filtA DEFAULT_VALUE true
set_parameter_property sup_filtA DISPLAY_NAME sup_filtA
set_parameter_property sup_filtA TYPE BOOLEAN
set_parameter_property sup_filtA UNITS None
set_parameter_property sup_filtA HDL_PARAMETER true
add_parameter sup_filtB BOOLEAN true
set_parameter_property sup_filtB DEFAULT_VALUE true
set_parameter_property sup_filtB DISPLAY_NAME sup_filtB
set_parameter_property sup_filtB TYPE BOOLEAN
set_parameter_property sup_filtB UNITS None
set_parameter_property sup_filtB HDL_PARAMETER true
add_parameter sup_filtC BOOLEAN true
set_parameter_property sup_filtC DEFAULT_VALUE true
set_parameter_property sup_filtC DISPLAY_NAME sup_filtC
set_parameter_property sup_filtC TYPE BOOLEAN
set_parameter_property sup_filtC UNITS None
set_parameter_property sup_filtC HDL_PARAMETER true
add_parameter sup_range BOOLEAN true
set_parameter_property sup_range DEFAULT_VALUE true
set_parameter_property sup_range DISPLAY_NAME sup_range
set_parameter_property sup_range TYPE BOOLEAN
set_parameter_property sup_range UNITS None
set_parameter_property sup_range HDL_PARAMETER true
add_parameter sup_traffic_ctrs BOOLEAN true
set_parameter_property sup_traffic_ctrs DEFAULT_VALUE true
set_parameter_property sup_traffic_ctrs DISPLAY_NAME sup_traffic_ctrs
set_parameter_property sup_traffic_ctrs TYPE BOOLEAN
set_parameter_property sup_traffic_ctrs UNITS None
set_parameter_property sup_traffic_ctrs HDL_PARAMETER true


# 
# display items
# 


# 
# connection point clock_sink
# 
add_interface clock_sink clock end
set_interface_property clock_sink clockRate 0
set_interface_property clock_sink ENABLED true
set_interface_property clock_sink EXPORT_OF ""
set_interface_property clock_sink PORT_NAME_MAP ""
set_interface_property clock_sink CMSIS_SVD_VARIABLES ""
set_interface_property clock_sink SVD_ADDRESS_GROUP ""

add_interface_port clock_sink clk_sys clk Input 1


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock ""
set_interface_property reset_sink synchronousEdges NONE
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink CMSIS_SVD_VARIABLES ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink res_n reset_n Input 1


# 
# connection point interrupt_sender
# 
add_interface interrupt_sender interrupt end
set_interface_property interrupt_sender associatedAddressablePoint registers
set_interface_property interrupt_sender associatedClock clock_sink
set_interface_property interrupt_sender associatedReset reset_sink
set_interface_property interrupt_sender bridgedReceiverOffset ""
set_interface_property interrupt_sender bridgesToReceiver ""
set_interface_property interrupt_sender ENABLED true
set_interface_property interrupt_sender EXPORT_OF ""
set_interface_property interrupt_sender PORT_NAME_MAP ""
set_interface_property interrupt_sender CMSIS_SVD_VARIABLES ""
set_interface_property interrupt_sender SVD_ADDRESS_GROUP ""

add_interface_port interrupt_sender int irq Output 1


# 
# connection point timestamp
# 
add_interface timestamp conduit end
set_interface_property timestamp associatedClock clock_sink
set_interface_property timestamp associatedReset ""
set_interface_property timestamp ENABLED true
set_interface_property timestamp EXPORT_OF ""
set_interface_property timestamp PORT_NAME_MAP ""
set_interface_property timestamp CMSIS_SVD_VARIABLES ""
set_interface_property timestamp SVD_ADDRESS_GROUP ""

add_interface_port timestamp timestamp timestamp Input 64


# 
# connection point can_interface
# 
add_interface can_interface conduit end
set_interface_property can_interface associatedClock ""
set_interface_property can_interface associatedReset ""
set_interface_property can_interface ENABLED true
set_interface_property can_interface EXPORT_OF ""
set_interface_property can_interface PORT_NAME_MAP ""
set_interface_property can_interface CMSIS_SVD_VARIABLES ""
set_interface_property can_interface SVD_ADDRESS_GROUP ""

add_interface_port can_interface can_rx can_rx Input 1
add_interface_port can_interface can_tx can_tx Output 1


# 
# connection point registers
# 
add_interface registers avalon end
set_interface_property registers addressUnits SYMBOLS
set_interface_property registers associatedClock clock_sink
set_interface_property registers associatedReset reset_sink
set_interface_property registers bitsPerSymbol 8
set_interface_property registers burstOnBurstBoundariesOnly false
set_interface_property registers burstcountUnits WORDS
set_interface_property registers explicitAddressSpan 0
set_interface_property registers holdTime 0
set_interface_property registers linewrapBursts false
set_interface_property registers maximumPendingReadTransactions 0
set_interface_property registers maximumPendingWriteTransactions 0
set_interface_property registers readLatency 1
set_interface_property registers readWaitStates 0
set_interface_property registers readWaitTime 0
set_interface_property registers setupTime 0
set_interface_property registers timingUnits Cycles
set_interface_property registers writeWaitTime 0
set_interface_property registers ENABLED true
set_interface_property registers EXPORT_OF ""
set_interface_property registers PORT_NAME_MAP ""
set_interface_property registers CMSIS_SVD_VARIABLES ""
set_interface_property registers SVD_ADDRESS_GROUP ""

add_interface_port registers data_in writedata Input 32
add_interface_port registers data_out readdata Output 32
add_interface_port registers adress address Input 16
add_interface_port registers scs chipselect Input 1
add_interface_port registers srd read Input 1
add_interface_port registers swr write Input 1
add_interface_port registers sbe byteenable Input 4
set_interface_assignment registers embeddedsw.configuration.isFlash 0
set_interface_assignment registers embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment registers embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment registers embeddedsw.configuration.isPrintableDevice 0

