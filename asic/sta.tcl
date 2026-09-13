# Pre-layout static timing analysis of the Yosys netlist (zero wire delay).
# Run from the repo root:
#   /ExternalDisk/Git/OpenROAD-flow-scripts/tools/install/OpenROAD/bin/sta -no_splash -exit asic/sta.tcl

read_liberty /ExternalDisk/Git/OpenROAD-flow-scripts/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib
read_verilog asic/yosys/fpadd_netlist.v
link_design fpadd_top
read_sdc asic/constraint.sdc

report_checks -path_delay max -fields {slew cap fanout} -digits 3
report_wns
report_tns
