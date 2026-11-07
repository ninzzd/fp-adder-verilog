# Leading Zero Detection
**File(s)**: [`p_encoder`][p_encoder], [`resm_p_encoder`][resm_p_encoder]
## Purpose
- To detect leading zeros in the result mantissa (after 2s complementing) and produce the left-shift amount for result mantissa renormalization
## Architectural Decisions
### Priority Encoder
- A general N:1 priority encoder implements the following truth table:

    | $a_{N-1}$ | $a_{N-2}$ | ... | $a_0$ | $f$ |
    |---| --- |---|---|---|
    | 1 | x | ... | x | $f_{N-1}$ |
    | 0 | 1 | ... | x | $f_{N-2}$ |
    | 0 | 0 | ... | 1 | $f_{0}$ |
- This truth table can be logically simplified as:
```math
f = a_{N-1} f_{N-1} + \overline{a_{N-1}} a_{N-2} f_{N-2} + \dots + \overline{a_{N-1}} \overline{a_{N-2}} \dots a_0 f_0
```
- This was implemented in [`p_encoder`][p_encoder] using a `generate` loop block for generating the minterms, and a reduction-OR for obtaining the output function.
- A `p_encoder` module inputs an `N`-bit function vector `f`, which generalizes the LUT and implements the above truth table.
- A zero-input vector generates a default output of `1'b0`, which is not handled separately here.
### Leading Zero Detector
- This is implemented in [`resm_p_encoder`][resm_p_encoder] in two steps: first find the **position** of the leading 1, then convert that position into a leading-zero count.
- **Position of the leading 1.** `le` parallel N:1 priority encoders are instantiated using a `generate` loop, with `N = lm+4` (the internal mantissa width). Encoder $PE_i$ produces bit `i` of the position, so its function vector holds bit `i` of every possible position `j`:

```math
    F_i[j] = \lfloor\frac{j}{2^i}\rfloor \pmod 2 = (j >> i)[0]
```
- The second notation is bit `i` of `j`, which is a single constant wire per entry in Verilog (`assign temp = j >> i;` into a 1-bit wire). Encoders with $2^i > lm+3$ have an all-zero function vector and output a constant 0.
- **Leading-zero count.** For a leading 1 at position `p`, the number of leading zeros in the `lm+4`-bit vector is $(lm+3) - p$. This is computed with a CLA subtractor, with the constant `lm+3` held in `le` bits:
```math
    shamt = (lm + 3) - p
```
- `le` encoders are used, rather than just enough for `lm+4` positions, because `shamt` feeds the `le`-bit exponent subtractor and `min` circuit directly. For the same reason, `lm+3` must be representable in `le` bits, which gives the validity constraint $2^{le}-1 \ge lm+3$ (see [Datapath Overview](./datapath.md#parameters)).
- Zero-input vectors are handled by a reduction-NOR on the input, `isZero = ~|resm`. For an all-zero input every encoder outputs 0, so `shamt` reads as `lm+3`; the result exponent is overridden to zero by `isZero` instead (see [Normalization](./normalization.md#subtraction-path-capped-left-shift)).

## Architectural Diagram
Refer to the *Priority Encoder* block and its `isZero` and `shamt` outputs in the [microarchitectural diagram](../README.md#architecture).

[p_encoder]: ../rtl/utils/p_encoder.v
[resm_p_encoder]: ../rtl/datapath/resm_p_encoder.v
