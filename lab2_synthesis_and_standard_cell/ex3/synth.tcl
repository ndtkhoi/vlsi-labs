set_db init_lib_search_path {/home/yellow/ee3201_19/Desktop/LAB2/PDK45nm/gpdk045_lib}
set_db init_hdl_search_path {/home/yellow/ee3201_19/Desktop/LAB2/ex3/00_src}

read_libs slow_vdd1v2_basicCells_lvt.lib
										#check khi doi lib					

read_hdl -sv dff.sv
elaborate

create_clock -name clk -period 10 [get_ports i_clk]

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

syn_generic
syn_map
#syn_opt

										#check khi doi lib
report_timing -max_paths 50 > 02_reports/slow_vdd1v2_lvt/timing.rpt		
report_power	> 02_reports/slow_vdd1v2_lvt/power.rpt				
report_area	> 02_reports/slow_vdd1v2_lvt/area.rpt				
report_qor	> 02_reports/slow_vdd1v2_lvt/qor.rpt				

										#check khi doi lib
write_hdl	> 03_outputs/slow_vdd1v2_lvt/netlist.sv	
										
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > 03_outputs/slow_vdd1v2_lvt/delay.sdf
		



