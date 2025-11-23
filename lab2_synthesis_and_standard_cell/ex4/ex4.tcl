# ex4_s1v2h.tcl

# ==== Đường dẫn thư viện & source ===
set_db init_lib_search_path {/home/yellow/ee3201_19/Desktop/LAB2/ex4/gpdk045_lib}
set_db init_hdl_search_path {/home/yellow/ee3201_19/Desktop/LAB2/ex4/00_src}

# ==== doc thu vien corner slow 1.2V HVT ==
read_libs slow_vdd1v2_basicCells_hvt.lib

# ==== doc RTL ==
read_hdl -sv ex4.sv
elaborate

# them neu muon chac
# set_db hdl_top ex4

# ==== thiet lap  effort ====
set_db syn_generic_effort medium
set_db syn_map_effort     medium
set_db syn_opt_effort     medium

# ====  tổng hợp ====
syn_generic
syn_map
# syn_opt   ;#  bac neu muon toi uu

# ==== Report (ko có constra) ====
report_timing > 02_reports/ex4_timing_s1v2h.rpt
report_power  > 02_reports/ex4_power_s1v2h.rpt
report_area   > 02_reports/ex4_area_s1v2h.rpt
report_qor    > 02_reports/ex4_qor_s1v2h.rpt

# ==== Ghi netlist + SDF ====
write_hdl > 03_outputs/ex4_netlist_s1v2h.sv

write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > 03_outputs/ex4_delay_s1v2h.sdf

