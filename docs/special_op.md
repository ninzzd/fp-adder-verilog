# Special Operands
**File(s)**: [`special_op`][special_op], [`fpadd.v`][fpadd]
## Purpose
- To detect infinity, sNaN and qNaN operands, which the main datapath cannot handle arithmetically.
- To decide, in parallel with the main datapath, whether its result must be overridden by an infinity or a NaN.
- To catch the overflow of a finite result to infinity, and to assemble the final output word.

## Architectural Decisions
### Operand Classification
- All special values have an all-ones exponent field, and are told apart by the mantissa field (see [Theory](./theory.md#nans)):
```verilog
assign a_is_inf  = &(a[lm+le-1:lm]) & ~|(a[lm-1:0]);                // mantissa all zeros
assign a_is_snan = &(a[lm+le-1:lm]) & ~a[lm-1] & |(a[lm-2:0]);      // MSB 0, rest non-zero
assign a_is_qnan = &(a[lm+le-1:lm]) & a[lm-1];                      // MSB 1, rest don't-care
```
- The qNaN check deliberately ignores the lower mantissa bits, so qNaNs with any payload are caught, not just the canonical one. The reduction OR is only needed for the sNaN check, to tell an sNaN apart from an infinity.

    (*Check out [Test 12](./logs/running_doc.md#test-12), where only canonical qNaNs were being detected*)

### Override Decision
- The unit outputs a 2-bit code `sop_out`, decided in priority order:

    | Condition | `sop_out` | Result |
    |---|:---:|---|
    | Either operand is a NaN | `10` | Canonical qNaN |
    | Both operands are infinite and `maddop = 1` | `10` | Canonical qNaN ($\infty - \infty$ is invalid) |
    | Either operand is infinite | `01` | $\pm\infty$ |
    | Otherwise | `00` | Main datapath result |
- `maddop = sa ^ sb ^ op` decides whether two infinities cancel, since it already accounts for both signs and the requested operation. For example, $(+\infty) + (-\infty)$ and $(+\infty) - (+\infty)$ both have `maddop = 1`.

    (*Check out [Test 9](./logs/running_doc.md#test-9), where every pair of infinities produced an infinity*)
- An sNaN operand produces the canonical qNaN, the same as a qNaN operand. The adder has no exception-flag outputs, so the invalid-operation signal that IEEE 754 associates with an sNaN is not reported.

### Sign of an Infinite Result
- `special_op` does not compute a sign for the infinity. The main datapath's `res_sign` is used instead, and it is already correct:
    - An infinite operand has the largest possible exponent, so it always becomes $A_0$.
    - Against a finite operand, the aligned mantissa of $B_0$ is strictly smaller than that of $A_0$, so `flag = 0`. For two infinities with `maddop = 0`, the mantissas are equal and the adder does not need to complement either.
    - Hence `res_sign` reduces to the sign of the infinite term, including the inversion when $A_0$ is $B$ and the operation is a subtraction.

    (*Check out [Test 10](./logs/running_doc.md#test-10), where the infinity's sign was taken from `maddop`*)

### Overflow to Infinity
- A finite result overflows when the result exponent reaches all ones, either through the addition-path carry or the rounding carry (see [Normalization](./normalization.md#addition-path-right-shift-by-1) and [Rounding](./rounding.md#exponent-adjustment-for-rounding-overflow)). The exponent then already encodes infinity, and only the mantissa needs clearing:
```verilog
assign res_notinf = ~&(res_exp);
assign res_man = resm[lm-1:0] & {lm{res_notinf}};
```

### Output Assembly
- The final word combines the main datapath result (`res_sign`, `res_exp`, `res_man`) with the override:
```verilog
assign c[lm+le] = res_sign & ~sop_out[1];               // NaN is always positive
assign c[lm+le-1:lm] = res_exp | {le{sop_out_or}};      // all ones for inf and NaN
// c[lm-1]: sop_out[1] if overridden (1 for NaN, 0 for inf), else res_man[lm-1]
assign c[lm-2:0] = res_man[lm-2:0] & ~{(lm-1){sop_out_or}};
```
- The NaN output is always the **canonical qNaN**: sign 0, exponent all ones, mantissa `10…0`, whatever the payloads or signs of the input NaNs. This is a deliberate design choice that removes payload-forwarding logic and makes every NaN result bit-identical.

## Architectural Diagram
The special-operand unit and the overflow mask were added after the [microarchitectural diagram](../README.md#architecture) was drawn, and do not appear in it.

[special_op]: ../rtl/datapath/special_op.v
[fpadd]: ../rtl/fpadd.v
