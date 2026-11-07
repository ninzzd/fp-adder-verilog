# Normalization
**File(s)**: [`resm_l_shifter`][resm_l_shifter], [`fpadd.v`][fpadd]
## Purpose
- To bring the `lm+4`-bit result mantissa `maddres_2s` back into the normalized form `1.xxx | G R S`, after the mantissa adder has either overflowed (addition) or produced leading zeros (subtraction).
- To compensate the result exponent by the same amount the mantissa was shifted, so that the represented value is unchanged.
- To stop the renormalization at the sub-normal boundary, and to produce a zero exponent for an exactly-zero result.

## Architectural Decisions
### Two Separate Paths
- The two effective operations need opposite kinds of shift (see [Theory](./theory.md#mantissa-addition-and-subtraction)):
    - **Addition** (`maddop = 0`): the sum is always below 4, so it needs at most a 1-bit right-shift.
    - **Subtraction** (`maddop = 1`): the difference can have up to `lm+1` leading zeros, so it needs a variable left-shift.
- Both paths are computed in parallel, and the result is chosen by `maddop` through two 2:1 muxes:
    - `add_sub_resm_mux` selects the mantissa: `maddres_ls` (subtraction) or `maddres_rs` (addition), giving `resm_bround`.
    - `add_sub_rese_mux` selects the exponent: `resesub` (subtraction) or `reseadd` (addition), giving `rese_bround`.

### Addition Path: Right-Shift by 1
- When the mantissa adder carries out (`maddcout = 1`), the carry becomes the new leading bit and everything moves down by one position. The bit that falls off the end is OR-merged into the sticky bit, so no non-zero information is lost (`S_new = R | S`):
```verilog
.in({{maddcout,maddres_2s[lm+3:2],maddres_2s[1]|maddres_2s[0]},maddres_2s}),
.sel(maddcout),
```
- The exponent is incremented in lock-step by an `inc` whose carry-in is `maddcout`: `reseadd = a0e + maddcout`. If `a0e` was already the largest finite exponent, `reseadd` becomes all-ones, which is caught later as an overflow to infinity (see [Special Operands](./special_op.md#overflow-to-infinity)).
- Adding two sub-normals can produce a leading 1 at bit `lm+3` without any carry-out. Because sub-normal exponents were pre-incremented to 1 (see [Nomenclature](./nomenclature.md#sub-normal-adjustment)), the exponent is already correct for the smallest normal number, so this sub-normal-to-normal transition needs no extra logic.

### Subtraction Path: Capped Left-Shift
- The [Leading Zero Detector](./leading_zero_detector.md) counts the leading zeros of `maddres_2s` as `maddres_lshamt`, and flags an all-zero result as `maddres_isZero`.
- Shifting left by the full leading-zero count could push the exponent below the sub-normal range. In this datapath, the sub-normal domain begins at an internal exponent of **1**, not 0, because of the sub-normal pre-increment. Hence the shift is capped at $E_{A_0} - 1$:
$$
shamt_{L} = \min\big(E_{A_0}-1,\; lz\big)
$$
- This is built from a `dec` (`a0e_dec`, giving `a0e_sub_1`) and a `min` (`a0e_lshamt_cap`, giving `a0e_lshamt_min`), both at the full `le`-bit width. When the cap is the smaller value, the result is left with an exponent of 1 and no leading 1, i.e. a sub-normal, which is detected and encoded after rounding (see [Rounding](./rounding.md#sub-normal-result-detection-and-exponent-field-masking)).

    (*Check out [Test 7](./logs/running_doc.md#test-7), where the cap was first $E_{A_0}$ and every sub-normal result was shifted one place too far*)
- The exponent is reduced by the same capped amount using a CLA subtractor (`rese_sub`): `resesub = a0e - a0e_lshamt_min`.
- For an exactly-zero result there is no leading 1 to find, so the exponent is overridden to zero instead: `resesub & {le{~maddres_isZero}}`. The sign of a zero result is handled separately (see [Mantissa Adder Operation Logic and Output Sign](./manop_outsign.md#handling-zero-result)).

### Left Shifter
- [`resm_l_shifter`][resm_l_shifter] is a barrel shifter with one `(lm+4):1` mux per output bit. Output bit `i` selects `in[i-j]` for a shift of `j`, and a shifted-in `0` for `j > i`:
```verilog
if(j <= i)
    assign mux_in[j] = in[i-j];
else
    assign mux_in[j] = 1'b0;
```
- Since the whole `lm+4`-bit vector (including `G R S`) is shifted, the guard and round bits move up into the mantissa during heavy cancellation, which is why they were kept during alignment.
- The select is truncated to `$clog2(lm+3)` bits instead of being clipped with a `min`. This is safe because a large left-shift is only needed when the operand exponents differ by at most 1, and then no bit was shifted below the guard position, so a non-zero difference has at most `lm+1` leading zeros. The only larger count, `lm+3`, comes from an all-zero result, which stays zero for any shift.

## Architectural Diagram
Refer to the *Priority Encoder*, *DEC*, *min(A, B)*, *Left Shift*, the exponent subtractor beneath them, and the *RS-1* block with its `0/1` mux in the [microarchitectural diagram](../README.md#architecture).

[resm_l_shifter]: ../rtl/datapath/resm_l_shifter.v
[fpadd]: ../rtl/fpadd.v
