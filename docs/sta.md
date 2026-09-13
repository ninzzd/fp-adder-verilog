# Static Timing Analysis

Run pre-layout STA (zero wire delay) on the Yosys netlist from [synthesis](./synthesis.md), using `asic/sta.tcl` and `asic/constraint.sdc` (run from the repo root):
```bash
/ExternalDisk/Git/OpenROAD-flow-scripts/tools/install/OpenROAD/bin/sta -no_splash -exit asic/sta.tcl
```

## Results

`fpadd_top`, fp32 (`lm=23`, `le=8`), nangate45 typical library, 5.0 ns clock, OpenSTA 3.1.0, area-oriented netlist (all cells X1, no timing target during synthesis).

| Metric | Value |
|---|---|
| Clock period | 5.000 ns |
| Data arrival time (worst path) | 5.778 ns |
| Data required time | 4.891 ns |
| Worst slack (WNS) | −0.886 ns (violated) |
| Total negative slack (TNS) | −23.83 ns |
| Launching flop clock-to-Q | 0.098 ns |
| Combinational delay on worst path | 5.680 ns |
| Logic depth on worst path | 56 cells |
| Minimum period (5.0 − WNS) | ≈ 5.886 ns (≈ 170 MHz) |

Worst setup path:
```text
Fanout      Cap     Slew    Delay     Time   Description
---------------------------------------------------------------------------------
                   0.000    0.000    0.000   clock clk (rise edge)
                            0.000    0.000   clock network delay (ideal)
                   0.000    0.000    0.000 ^ _3707_/CK (DFFR_X1)
     8   10.117    0.015    0.098    0.098 v _3707_/Q (DFFR_X1)
     2    3.324    0.058    0.098    0.196 ^ _1876_/ZN (NOR4_X1)
     4    5.402    0.023    0.033    0.229 v _1893_/ZN (AOI21_X1)
     2    3.242    0.048    0.081    0.310 ^ _1913_/ZN (AOI211_X1)
     2    2.998    0.016    0.034    0.344 v _1917_/ZN (OAI22_X1)
     2    3.356    0.053    0.093    0.437 ^ _1924_/ZN (AOI221_X1)
     7    9.851    0.025    0.045    0.482 v _1928_/ZN (AOI211_X1)
    52   91.095    0.430    0.488    0.970 ^ _1931_/ZN (NOR2_X1)
     4    5.998    0.017    0.069    1.040 v _2124_/Z (MUX2_X1)
     4    5.886    0.083    0.122    1.162 ^ _2133_/ZN (NOR4_X1)
     3    4.671    0.032    0.050    1.212 v _2136_/ZN (NAND4_X1)
     4    6.626    0.089    0.139    1.351 ^ _2139_/ZN (NOR4_X1)
     4    6.168    0.036    0.057    1.407 v _2142_/ZN (NAND4_X1)
     2    3.324    0.058    0.105    1.512 ^ _2144_/ZN (NOR4_X1)
     4    6.168    0.040    0.054    1.566 v _2147_/ZN (NAND4_X1)
     2    3.361    0.058    0.106    1.672 ^ _2149_/ZN (NOR4_X1)
     2    2.278    0.014    0.013    1.685 v _2152_/ZN (NOR2_X1)
    13   20.826    0.224    0.272    1.956 ^ _2173_/ZN (NOR4_X1)
     5    6.655    0.060    0.093    2.049 v _2358_/ZN (NAND4_X1)
     4    5.311    0.014    0.076    2.125 v _2442_/ZN (OR2_X1)
     4    5.884    0.014    0.061    2.186 v _2444_/ZN (OR2_X1)
     3    5.042    0.050    0.073    2.259 ^ _2553_/ZN (NOR3_X1)
    26   52.670    0.137    0.107    2.366 v _2675_/ZN (NOR3_X1)
     4    5.721    0.086    0.088    2.455 v _2743_/ZN (XNOR2_X1)
     4    4.549    0.021    0.146    2.601 v _2744_/ZN (OR4_X1)
     5    7.087    0.024    0.136    2.736 v _2748_/ZN (OR4_X1)
     3    4.009    0.021    0.097    2.833 v _2893_/ZN (OR4_X1)
     5    9.450    0.027    0.141    2.974 v _2943_/ZN (OR4_X1)
     1    2.574    0.054    0.094    3.068 ^ _2946_/ZN (NOR4_X1)
    11   14.728    0.037    0.061    3.129 v _2947_/ZN (XNOR2_X1)
     4    6.306    0.086    0.123    3.252 ^ _2952_/ZN (NOR4_X1)
     3    3.773    0.035    0.053    3.304 v _2969_/ZN (NAND4_X1)
     5    7.562    0.098    0.136    3.440 ^ _2976_/ZN (NOR4_X1)
     3    3.507    0.014    0.052    3.492 ^ _2977_/ZN (AND2_X1)
     3    5.040    0.022    0.069    3.561 ^ _3038_/ZN (AND4_X1)
     5    8.136    0.022    0.032    3.593 v _3054_/ZN (OAI21_X1)
     4    5.523    0.022    0.063    3.656 v _3064_/Z (XOR2_X1)
     1    1.525    0.015    0.032    3.688 ^ _3066_/ZN (NOR2_X1)
     1    1.574    0.014    0.024    3.711 v _3081_/ZN (OAI211_X1)
    12   22.820    0.192    0.239    3.950 ^ _3084_/ZN (AOI221_X1)
     9   15.131    0.040    0.091    4.041 ^ _3144_/Z (MUX2_X1)
    13   18.558    0.056    0.077    4.118 v _3174_/ZN (NAND3_X1)
    21   34.351    0.167    0.212    4.330 ^ _3180_/ZN (NOR2_X1)
     1    1.410    0.030    0.019    4.349 v _3428_/ZN (AOI22_X1)
     2    3.216    0.038    0.048    4.397 ^ _3429_/ZN (AOI21_X1)
     7    9.548    0.037    0.053    4.450 v _3447_/ZN (OAI211_X1)
     6    9.275    0.114    0.169    4.619 ^ _3451_/ZN (NOR4_X1)
     6    7.709    0.041    0.065    4.684 v _3453_/ZN (NAND4_X1)
     4    5.287    0.022    0.137    4.820 v _3455_/ZN (OR4_X1)
     6   10.080    0.123    0.169    4.989 ^ _3475_/ZN (NOR4_X1)
     4    5.351    0.034    0.055    5.044 v _3478_/ZN (NAND4_X1)
     5    7.590    0.100    0.150    5.194 ^ _3481_/ZN (NOR4_X1)
     4    6.361    0.040    0.071    5.265 v _3510_/ZN (NAND4_X1)
     2    2.468    0.024    0.048    5.313 ^ _3517_/ZN (XNOR2_X1)
     2    2.447    0.019    0.031    5.344 v _3550_/ZN (NAND4_X1)
    20   32.839    0.338    0.417    5.761 ^ _3551_/ZN (NOR4_X1)
     1    1.053    0.056    0.017    5.778 v _3642_/ZN (OAI21_X1)
                   0.056    0.000    5.778 v _3736_/D (DFFR_X1)
                                     5.778   data arrival time

                   0.000    5.000    5.000   clock clk (rise edge)
                            0.000    5.000   clock network delay (ideal)
                           -0.050    4.950   clock uncertainty
                            0.000    4.950   clock reconvergence pessimism
                                     4.950 ^ _3736_/CK (DFFR_X1)
                           -0.059    4.891   library setup time
                                     4.891   data required time
---------------------------------------------------------------------------------
                                     4.891   data required time
                                    -5.778   data arrival time
---------------------------------------------------------------------------------
                                    -0.886   slack (VIOLATED)


wns max -0.89
tns max -23.83
```

## Hold Analysis

Run the same script with setup (`max`) checks switched to hold (`min`) checks, without editing `asic/sta.tcl`:
```bash
/ExternalDisk/Git/OpenROAD-flow-scripts/tools/install/OpenROAD/bin/sta -no_splash -exit <(sed 's/-path_delay max/-path_delay min/; s/report_wns/report_wns -min/; s/report_tns/report_tns -min/' asic/sta.tcl)
```

### Results

| Metric | Value |
|---|---|
| Data arrival time (shortest path) | 0.167 ns |
| Data required time | 0.056 ns |
| Worst hold slack | +0.111 ns (met) |
| WNS / TNS (hold) | 0.00 / 0.00 |
| Launching flop clock-to-Q | 0.106 ns |
| Library hold time (`DFFR_X1`) | 0.006 ns |
| Logic depth on shortest path | 4 cells |

Worst hold path:
```text
Startpoint: _3697_ (rising edge-triggered flip-flop clocked by clk)
Endpoint: _3736_ (rising edge-triggered flip-flop clocked by clk)
Path Group: clk
Path Type: min

Fanout      Cap     Slew    Delay     Time   Description
---------------------------------------------------------------------------------
                   0.000    0.000    0.000   clock clk (rise edge)
                            0.000    0.000   clock network delay (ideal)
                   0.000    0.000    0.000 ^ _3697_/CK (DFFR_X1)
     3    4.398    0.015    0.106    0.106 ^ _3697_/Q (DFFR_X1)
     1    1.562    0.006    0.011    0.117 v _3622_/ZN (NOR4_X1)
     1    1.690    0.009    0.014    0.132 ^ _3629_/ZN (NAND3_X1)
     2    3.048    0.009    0.017    0.149 v _3639_/ZN (AOI22_X1)
     1    1.128    0.010    0.018    0.167 ^ _3642_/ZN (OAI21_X1)
                   0.010    0.000    0.167 ^ _3736_/D (DFFR_X1)
                                     0.167   data arrival time

                   0.000    0.000    0.000   clock clk (rise edge)
                            0.000    0.000   clock network delay (ideal)
                            0.050    0.050   clock uncertainty
                            0.000    0.050   clock reconvergence pessimism
                                     0.050 ^ _3736_/CK (DFFR_X1)
                            0.006    0.056   library hold time
                                     0.056   data required time
---------------------------------------------------------------------------------
                                     0.056   data required time
                                    -0.167   data arrival time
---------------------------------------------------------------------------------
                                     0.111   slack (MET)


wns min 0.00
tns min 0.00
```
