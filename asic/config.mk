# ORFS design config for fpadd_top on nangate45.
# Run from OpenROAD-flow-scripts/flow after `source ../env.sh`:
#   make DESIGN_CONFIG=/ExternalDisk/Git/fp-adder-verilog/asic/config.mk synth

export DESIGN_NICKNAME = fpadd
export DESIGN_NAME     = fpadd_top
export PLATFORM        = nangate45

FPADD_ROOT := $(abspath $(dir $(DESIGN_CONFIG))..)

export VERILOG_FILES = $(sort $(wildcard $(FPADD_ROOT)/rtl/*.v \
                                         $(FPADD_ROOT)/rtl/utils/*.v \
                                         $(FPADD_ROOT)/rtl/datapath/*.v)) \
                       $(FPADD_ROOT)/asic/fpadd_top.v
export SDC_FILE      = $(FPADD_ROOT)/asic/constraint.sdc

# Write logs/, reports/, results/ and objects/ into this repo instead of ORFS's flow/
export WORK_HOME     = $(FPADD_ROOT)/asic/orfs

# Start low: the flat CLA is expected to be routing-congested
export CORE_UTILIZATION  = 35
export PLACE_DENSITY     = 0.50
export CORE_ASPECT_RATIO = 1
export CORE_MARGIN       = 2

# Over-fix max-capacitance by 20% (repair_design -cap_margin, integer percent):
# the first run left _3099_/ZN at 28.19 fF vs a 26.70 fF limit after routing
export CAP_MARGIN        = 20
