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
		create_bd_cell -type ip -vlnv xilinx.com:ip:jtag_axi:1.2 jtag_axi_0
		create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
		create_bd_cell -type ip -vlnv xilinx.com:user:cpu:1.0 cpu_0

		# Configure IPs
		set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25} CONFIG.USE_RESET {false} CONFIG.MMCM_CLKFBOUT_MULT_F {9.125} CONFIG.MMCM_CLKOUT0_DIVIDE_F {36.500} CONFIG.CLKOUT1_JITTER {181.828} CONFIG.CLKOUT1_PHASE_ERROR {104.359}] [get_bd_cells clk_wiz_0]
		set_property -dict [list CONFIG.PROTOCOL {2}] [get_bd_cells jtag_axi_0]

		# Add external pins
		create_bd_port -dir I -type rst rstn
		create_bd_port -dir I -type clk -freq_hz 100000000 clk
		create_bd_port -dir O -from 7 -to 0 -type data io_leds
		create_bd_port -dir O io_uart_tx
	endgroup

	# Wiring
	connect_bd_net [get_bd_ports rstn] [get_bd_pins proc_sys_reset_0/ext_reset_in]
	connect_bd_net [get_bd_pins jtag_axi_0/aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
	connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins cpu_0/rstn]

	connect_bd_net [get_bd_ports clk] [get_bd_pins clk_wiz_0/clk_in1]
	connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins cpu_0/clk]
	connect_bd_net [get_bd_pins jtag_axi_0/aclk] [get_bd_pins clk_wiz_0/clk_out1]
	connect_bd_net [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins clk_wiz_0/clk_out1]

	connect_bd_net [get_bd_ports io_leds] [get_bd_pins cpu_0/io_leds]
	connect_bd_net [get_bd_ports io_uart_tx] [get_bd_pins cpu_0/io_uart_tx]
	connect_bd_intf_net [get_bd_intf_pins jtag_axi_0/M_AXI] [get_bd_intf_pins cpu_0/j2a_master_axi]

	connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_0/dcm_locked]

	assign_bd_address -target_address_space /jtag_axi_0/Data [get_bd_addr_segs cpu_0/j2a_master_axi/reg0] -force

	validate_bd_design
	regenerate_bd_layout
	save_bd_design

	make_wrapper -files [get_files ${CPU_PROJ_DIR}/single-cycle-RISCV.srcs/sources_1/bd/bd_cpu/bd_cpu.bd] -top
	add_files -norecurse ${CPU_PROJ_DIR}/single-cycle-RISCV.gen/sources_1/bd/bd_cpu/hdl/bd_cpu_wrapper.vhd
	set_property top bd_cpu_wrapper [current_fileset]
}

proc cpu_build {} {
	launch_runs impl_1 -to_step write_bitstream -jobs 12
}
