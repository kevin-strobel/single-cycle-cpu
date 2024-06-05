# Store the folder this script is located in
set CPU_ROOT_DIR [file dirname [file normalize [info script]]]
set CPU_SRC_DIR ${CPU_ROOT_DIR}/src/cpu
set CPU_PROJ_DIR ${CPU_ROOT_DIR}/vivado

proc cpu_new {} {
	global CPU_PROJ_DIR
	global CPU_SRC_DIR

	close_project -quiet
	file delete -force $CPU_PROJ_DIR
	create_project single-cycle-RISCV $CPU_PROJ_DIR -part xc7a200tsbg484-1
	set_property board_part digilentinc.com:nexys_video:part0:1.2 [current_project]
	set_property target_language VHDL [current_project]
	set_property simulator_language VHDL [current_project]
	add_files ${CPU_SRC_DIR}/hdl
	set_property top cpu [current_fileset]

	add_files -fileset constrs_1 ${CPU_SRC_DIR}/constr

	add_files -fileset sim_1 ${CPU_SRC_DIR}/sim
}

proc cpu_bd {} {
	global CPU_SRC_DIR
	global CPU_PROJ_DIR

	ipx::package_project -root_dir ${CPU_SRC_DIR} -vendor xilinx.com -library user -taxonomy /UserIP
	set_property core_revision 2 [ipx::current_core]
	ipx::create_xgui_files [ipx::current_core]
	ipx::update_checksums [ipx::current_core]
	ipx::check_integrity [ipx::current_core]
	ipx::save_core [ipx::current_core]
	set_property  ip_repo_paths ${CPU_SRC_DIR} [current_project]
	update_ip_catalog

	ipx::unload_core ${CPU_SRC_DIR}/component.xml
	create_bd_design "bd_cpu"

	startgroup
		# Add IPs
		create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
		create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
		create_bd_cell -type ip -vlnv xilinx.com:user:cpu:1.0 cpu_0

		# Configure IPs
		set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25} CONFIG.USE_RESET {false} CONFIG.MMCM_CLKFBOUT_MULT_F {9.125} CONFIG.MMCM_CLKOUT0_DIVIDE_F {36.500} CONFIG.CLKOUT1_JITTER {181.828} CONFIG.CLKOUT1_PHASE_ERROR {104.359}] [get_bd_cells clk_wiz_0]

		# Add external pins
		create_bd_port -dir I -type rst rstn
		create_bd_port -dir I -type clk -freq_hz 100000000 clk
		create_bd_port -dir O -from 7 -to 0 -type data gpio_leds
	endgroup

	# Wiring
	connect_bd_net [get_bd_ports rstn] [get_bd_pins proc_sys_reset_0/ext_reset_in]
	connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins cpu_0/rstn]

	connect_bd_net [get_bd_ports clk] [get_bd_pins clk_wiz_0/clk_in1]
	connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins cpu_0/clk]
	connect_bd_net [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins clk_wiz_0/clk_out1]

	connect_bd_net [get_bd_ports gpio_leds] [get_bd_pins cpu_0/gpio_leds]

	connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_0/dcm_locked]

	validate_bd_design
	regenerate_bd_layout
	save_bd_design

	make_wrapper -files [get_files ${CPU_PROJ_DIR}/single-cycle-RISCV.srcs/sources_1/bd/bd_cpu/bd_cpu.bd] -top
	add_files -norecurse ${CPU_PROJ_DIR}/single-cycle-RISCV.gen/sources_1/bd/bd_cpu/hdl/bd_cpu_wrapper.vhd
	set_property top bd_cpu_wrapper [current_fileset]
}




# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## project
#
## export HDMI IP
#ipx::package_project -root_dir $PROJDIR -vendor xilinx.com -library user -taxonomy /UserIP -import_files -set_current false
#ipx::unload_core $PROJDIR/component.xml
#ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $PROJDIR $PROJDIR/component.xml
#set_property core_revision 2 [ipx::current_core]
#ipx::update_source_project_archive -component [ipx::current_core]
#ipx::create_xgui_files [ipx::current_core]
#ipx::update_checksums [ipx::current_core]
#ipx::check_integrity [ipx::current_core]
#ipx::save_core [ipx::current_core]
#ipx::move_temp_component_back -component [ipx::current_core]
#close_project -delete
#set_property  ip_repo_paths  $PROJDIR [current_project]
#update_ip_catalog
#
#
## add I/O constraints
#add_files -fileset constrs_1 $SRCDIR/constrs/constr.xdc
#
## block design
#
#create_bd_design "demo_bd"
#startgroup
#create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
#create_bd_cell -type ip -vlnv xilinx.com:user:demo:1.0 demo_0
#set_property -dict [list CONFIG.CLKOUT2_USED {true} CONFIG.CLK_OUT1_PORT {clk_25} CONFIG.CLK_OUT2_PORT {clk_250} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {250} CONFIG.USE_LOCKED {false} CONFIG.USE_RESET {false} CONFIG.MMCM_CLKOUT0_DIVIDE_F {40.000} CONFIG.MMCM_CLKOUT1_DIVIDE {4} CONFIG.NUM_OUT_CLKS {2} CONFIG.CLKOUT1_JITTER {175.402} CONFIG.CLKOUT2_JITTER {110.209} CONFIG.CLKOUT2_PHASE_ERROR {98.575}] [get_bd_cells clk_wiz_0]
#make_bd_pins_external  [get_bd_pins clk_wiz_0/clk_in1]
#set_property name clk [get_bd_ports clk_in1_0]
#connect_bd_net [get_bd_pins clk_wiz_0/clk_25] [get_bd_pins demo_0/hdmi_pix_clk]
#connect_bd_net [get_bd_pins clk_wiz_0/clk_250] [get_bd_pins demo_0/hdmi_TMDS_clk]
#connect_bd_net [get_bd_ports clk] [get_bd_pins demo_0/clk]
#make_bd_pins_external  [get_bd_pins demo_0/hdmi_filter_r_off]
#make_bd_pins_external  [get_bd_pins demo_0/hdmi_filter_g_off]
#make_bd_pins_external  [get_bd_pins demo_0/hdmi_filter_b_off]
#make_bd_pins_external  [get_bd_pins demo_0/hdmi_filter_clk_off]
#make_bd_pins_external  [get_bd_pins demo_0/hdmi_filter_median_gray_en]
#make_bd_pins_external  [get_bd_pins demo_0/hdmi_show_counter]
#make_bd_pins_external  [get_bd_pins demo_0/counter_en]
#make_bd_pins_external  [get_bd_pins demo_0/counter_rshift]
#set_property name hdmi_filter_r_off [get_bd_ports hdmi_filter_r_off_0]
#set_property name hdmi_filter_g_off [get_bd_ports hdmi_filter_g_off_0]
#set_property name hdmi_filter_b_off [get_bd_ports hdmi_filter_b_off_0]
#set_property name hdmi_filter_clk_off [get_bd_ports hdmi_filter_clk_off_0]
#set_property name hdmi_show_counter [get_bd_ports hdmi_show_counter_0]
#set_property name hdmi_filter_median_gray_en [get_bd_ports hdmi_filter_median_gray_en_0]
#set_property name counter_en [get_bd_ports counter_en_0]
#set_property name counter_rshift [get_bd_ports counter_rshift_0]
#make_bd_pins_external  [get_bd_pins demo_0/hdmi_TMDSp]
#make_bd_pins_external  [get_bd_pins demo_0/hdmi_TMDSn]
#make_bd_pins_external  [get_bd_pins demo_0/hdmi_TMDSp_clk]
#make_bd_pins_external  [get_bd_pins demo_0/hdmi_TMDSn_clk]
#make_bd_pins_external  [get_bd_pins demo_0/counter_result_led]
#make_bd_pins_external  [get_bd_pins demo_0/counter_result_pmod]
#set_property name hdmi_TMDSp [get_bd_ports hdmi_TMDSp_0]
#set_property name hdmi_TMDSn [get_bd_ports hdmi_TMDSn_0]
#set_property name hdmi_TMDSp_clk [get_bd_ports hdmi_TMDSp_clk_0]
#set_property name hdmi_TMDSn_clk [get_bd_ports hdmi_TMDSn_clk_0]
#set_property name counter_result_led [get_bd_ports counter_result_led_0]
#set_property name counter_result_pmod [get_bd_ports counter_result_pmod_0]
#endgroup
#validate_bd_design
#regenerate_bd_layout
#save_bd_design
#
#make_wrapper -files [get_files $PROJDIR/HDMI.srcs/sources_1/bd/demo_bd/demo_bd.bd] -top
#add_files -norecurse $PROJDIR/HDMI.gen/sources_1/bd/demo_bd/hdl/demo_bd_wrapper.vhd
#set_property top demo_bd_wrapper [current_fileset]
#
#set_param synth.elaboration.rodinMoreOptions "rt::set_parameter max_loop_limit 400000"
#
#
## Write bitstream
#
#launch_runs impl_1 -to_step write_bitstream -jobs 12
#