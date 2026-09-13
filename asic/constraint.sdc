current_design fpadd_top

# Loose period for pre-layout STA: read the data arrival time, not the slack.
set clk_period 5.0; # default units - ns (set by the liberty .lib file, PDK node specific)
set clk_io_pct 0.1

create_clock -name clk -period $clk_period [get_ports clk]
set_clock_uncertainty 0.05 [get_clocks clk]

set non_clock_inputs [all_inputs -no_clocks]
set_input_delay  [expr $clk_period * $clk_io_pct] -clock clk $non_clock_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock clk [all_outputs]

set_false_path -from [get_ports rst_n]

set_driving_cell -lib_cell BUF_X2 -pin Z $non_clock_inputs
# One DFF_X1 D-pin load (nangate45 capacitance unit is fF)
set_load 1.14 [all_outputs]
