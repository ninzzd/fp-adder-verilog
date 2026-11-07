# Nomenclature
Refer to this file as a legend for various wire names in the [diagram](../README.md#architecture) and the main verilog module [fpadd.v](../rtl/fpadd.v). Wires marked "—" in the *Symbol* column have no label in the hand-drawn diagram; the special-operand unit and the overflow-to-inf mask were added after the diagram was drawn, and are described in [Special Operands](./special_op.md).

### Inputs and Output
| Symbol | Variable Name | Description |
|---|---|---|
| $S_A$ | `a[le+lm]` | Sign bit of operand `a` |
| $E_A$ | `a[le+lm-1:lm]` | Exponent bits of operand `a` |
| $M_A$ | `a[lm-1:0]` | Raw (stored) mantissa bits of operand `a`, excluding the implicit leading bit |
| $S_B$ | `b[le+lm]` | Sign bit of operand `b` |
| $E_B$ | `b[le+lm-1:lm]` | Exponent bits of operand `b` |
| $M_B$ | `b[lm-1:0]` | Raw (stored) mantissa bits of operand `b`, excluding the implicit leading bit |
| $op$ | `op` | Operation-select input: `0` = add, `1` = subtract |
| $S_C$ | `c[le+lm]` | Sign bit of the result |
| $E_C$ | `c[le+lm-1:lm]` | Exponent bits of the result |
| $M_C$ | `c[lm-1:0]` | Mantissa bits of the result |

### Sub-Normal Adjustment
| Symbol | Variable Name | Description |
|---|---|---|
| — | `na`, `nb` | 1 if the exponent field of `a`/`b` is non-zero (reduction OR); becomes the implicit leading mantissa bit |
| — | `am`, `bm` | `lm+1`-bit mantissas of `a`/`b` with the implicit leading bit restored: `{na, a[lm-1:0]}` |
| — | `ae_adj`, `be_adj` | Exponents of `a`/`b`, incremented by 1 if the operand is sub-normal (`ae_inc_sbnrm`/`be_inc_sbnrm`), so that sub-normal and normal operands share one exponent path |

### Exponent Comparison and Alignment
| Symbol | Variable Name | Description |
|---|---|---|
| $ageb$ | `ageb` | Output of the exponent comparator; 1 if `ae_adj >= be_adj`, used to select which operand becomes $A_0$/$B_0$ |
| $E_{A_0}$ | `a0e` | Exponent of $A_0$, i.e. the larger of the two (subnormal-adjusted) exponents |
| — | `a0m`, `b0m` | `lm+1`-bit mantissas of $A_0$ and $B_0$ after the swap |
| — | `a0s`, `b0s` | Raw sign bits of the operands that became $A_0$ and $B_0$ (`b0s` is currently unused) |
| $shamt$ | `b0_shamt` | Right-shift amount for $B_0$'s mantissa (absolute exponent difference), from the exponent comparator |
| $g$, $r$, $s$ | `b0m_shifted[2:0]` | Guard, round and sticky bits produced by the right-shifter |
| — | `b0m_shifted` | `lm+4`-bit aligned mantissa of $B_0$: `[lm+1-bit mantissa \| G R S]` |

### Mantissa Adder
| Symbol | Variable Name | Description |
|---|---|---|
| $MADD_{op}$ | `maddop` | Effective add/sub control fed to the mantissa adder: `sa ^ sb ^ op` |
| $MADD_c$ | `maddcout` | Carry-out of the mantissa adder |
| — | `maddres` | Raw `lm+4`-bit mantissa adder output |
| $flag$ | `flag` | 1 if the mantissa-adder result is negative and needs 2's-complementing: `maddop & ~maddcout` |
| — | `maddres_2s` | Magnitude of `maddres` (2's complemented when `flag` is set) |

### Normalization
| Symbol | Variable Name | Description |
|---|---|---|
| $isZero$ | `maddres_isZero` | 1 if `maddres_2s` is all zeros (exact cancellation) |
| — | `maddres_lshamt` | Leading-zero count of `maddres_2s`, from the priority encoder |
| $shamt'$ | `a0e_sub_1` | $E_{A_0} - 1$; combined with the leading-zero shift amount in a `min` circuit to cap the renormalization left-shift, preventing exponent underflow when the result is sub-normal |
| — | `a0e_lshamt_min` | `min(a0e_sub_1, maddres_lshamt)`: the capped left-shift amount actually applied |
| — | `maddres_ls` | Left-shifted (renormalized) mantissa, used on the subtraction path |
| — | `maddres_rs` | Mantissa after the conditional right-shift-by-1 on adder carry-out, used on the addition path |
| — | `resesub` | Result exponent on the subtraction path: `a0e - a0e_lshamt_min` |
| — | `reseadd` | Result exponent on the addition path: `a0e + maddcout` |

### Rounding and Output
| Symbol | Variable Name | Description |
|---|---|---|
| — | `resm_bround` | `lm+4`-bit result mantissa before rounding, selected from `maddres_ls`/`maddres_rs` by `maddop` |
| — | `rese_bround` | Result exponent before rounding, selected from `resesub`/`reseadd` by `maddop` (forced to 0 when `maddres_isZero`) |
| $R_{cout}$ | `round_cout` | Carry-out of the rounding incrementer |
| — | `resm_around` | `lm+1`-bit mantissa after the rounding increment |
| — | `resm` | `lm+1`-bit mantissa after the rounding-overflow right-shift |
| — | `rese_around` | Result exponent after the rounding-overflow increment |
| $isSubNrm$ | `resm_isSubnormal` | 1 if the rounded result mantissa is sub-normal |
| — | `res_sign` | Result sign from the main datapath |
| — | `res_exp` | Result exponent from the main datapath, with the sub-normal LSB adjustment undone |
| — | `res_notinf` | 0 when `res_exp` is all ones, i.e. the result overflowed to infinity |
| — | `res_man` | Result mantissa from the main datapath, forced to zero on overflow to infinity |
| — | `sop_out` | 2-bit special-operand override from `special_op`: `00` main datapath, `01` infinity, `10` canonical qNaN |
| — | `sop_out_or` | 1 if any special-operand override is active |
