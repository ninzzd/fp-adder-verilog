# Synthesis

Synthesize `fpadd_top` to a nangate45 gate-level netlist (run from the repo root):
```bash
Y=/ExternalDisk/Git/OpenROAD-flow-scripts/tools/install/yosys/bin/yosys; LIB=/ExternalDisk/Git/OpenROAD-flow-scripts/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib; mkdir -p asic/yosys && $Y -q -l asic/yosys/synth.log -p "read_verilog $(echo rtl/utils/*.v rtl/datapath/*.v) rtl/fpadd.v asic/fpadd_top.v; synth -top fpadd_top -flatten; dfflibmap -liberty $LIB; abc -liberty $LIB; opt_clean; tee -o asic/yosys/stat.txt stat -liberty $LIB; write_verilog -noattr asic/yosys/fpadd_netlist.v" && tail -30 asic/yosys/stat.txt
```

Check the synthesis log for warnings:
```bash
grep -i warning asic/yosys/synth.log | sort | uniq -c | sort -rn | head -20
```

View the synthesized netlist as text:
```bash
less asic/yosys/fpadd_netlist.v
```

Render the hierarchical (unflattened) schematic of `fpadd` to `asic/yosys/fpadd_hier.svg`; replace `fpadd` with any submodule name to view that block:
```bash
Y=/ExternalDisk/Git/OpenROAD-flow-scripts/tools/install/yosys/bin/yosys; $Y -q -p "read_verilog $(echo rtl/utils/*.v rtl/datapath/*.v) rtl/fpadd.v; hierarchy -top fpadd; proc; opt_clean; show -format svg -prefix asic/yosys/fpadd_hier fpadd" && xdg-open asic/yosys/fpadd_hier.svg
```

Render a gate-level schematic of a single module (here `add`) to `asic/yosys/add.svg`:
```bash
Y=/ExternalDisk/Git/OpenROAD-flow-scripts/tools/install/yosys/bin/yosys; LIB=/ExternalDisk/Git/OpenROAD-flow-scripts/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib; $Y -q -p "read_liberty -lib $LIB; read_verilog $(echo rtl/utils/*.v); synth -top add; abc -liberty $LIB; opt_clean; show -format svg -prefix asic/yosys/add add" && xdg-open asic/yosys/add.svg
```

## Results

`fpadd_top`, fp32 (`lm=23`, `le=8`), Yosys 0.68+ with ABC, nangate45 typical library, flattened, no timing target (all cells at X1 drive strength).

| Metric | Value |
|---|---|
| Total cell area | 2691.122 µm² |
| Sequential area (97 × `DFFR_X1`) | 516.040 µm² (19.18%) |
| Combinational area | 2175.082 µm² |
| Standard cells | 1889 (97 sequential, 1792 combinational) |
| Ports / port bits | 6 / 99 |
| Wires / wire bits | 2751 / 12283 |
| Synthesis warnings | 2 (ABC informational only) |

Largest contributors by area:

| Cell | Count | Area (µm²) |
|---|---|---|
| `DFFR_X1` | 97 | 516.040 |
| `AOI222_X1` | 82 | 174.496 |
| `NOR2_X1` | 215 | 171.570 |
| `XNOR2_X1` | 88 | 140.448 |
| `AOI22_X1` | 104 | 138.320 |
| `NAND2_X1` | 157 | 125.286 |
| `AOI21_X1` | 117 | 124.488 |
