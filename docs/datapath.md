# Datapath Overview
**File** - [`fpadd.v`](../rtl/fpadd.v)
## Purpose
- To give a stage-by-stage map of the top-level module `fpadd #(le, lm)(a, b, op, c)`, linking each stage to the document that describes it in detail.
- `fpadd` is purely combinational: `c = a + b` when `op = 0`, and `c = a - b` when `op = 1`, for a `(1, le, lm)` format, rounded to nearest-even.

## Parameters
- `lm` is the number of stored mantissa (fraction) bits, and `le` the number of exponent bits. The word width is `lm+le+1`, laid out as `{sign, exponent, fraction}`.
- The parameters must satisfy $2^{le} - 1 \ge lm + 3$. The leading-zero count is carried as an `le`-bit value, and it must be able to reach `lm+3`. For example, `lm = 6, le = 3` is not a valid configuration.

## Internal Mantissa Format
- From alignment until rounding, every mantissa is carried as an `lm+4`-bit vector:

    `[ lm+1-bit mantissa (with implicit leading bit) | G R S ]`

- `G`, `R` and `S` are the guard, round and sticky bits (see [Theory](./theory.md#guard-round-and-sticky-bits)). Rounding reduces the vector back to `lm+1` bits, and the leading bit is dropped on output.

## Stages
1. **Special operands.** [`special_op`](./special_op.md) classifies infinities and NaNs in parallel with the rest of the datapath, and decides whether the final result must be overridden.
2. **Sub-normal adjustment.** A non-zero exponent field becomes the implicit leading mantissa bit (`na`, `nb`). Sub-normal exponents are incremented from 0 to 1, so that sub-normal and normal operands share one exponent path.
3. **Exponent comparison and swap.** The [exponent comparator](./exponent_comparator.md) gives `ageb`, the shift amount `b0_shamt` and the larger exponent `a0e`. The operands are swapped so that $A_0$ has the larger exponent and $B_0$ the smaller.
4. **Alignment.** $B_0$'s mantissa is right-shifted by `b0_shamt`, capped at `lm+3`, into the `lm+4`-bit internal format (see [Mantissa Alignment](./mantissa_alignment.md)).
5. **Mantissa addition.** The CLA adds or subtracts the aligned mantissas according to `maddop = sa ^ sb ^ op`. A negative difference is complemented back to its magnitude, and the result sign is resolved (see [Mantissa Adder Operation Logic and Output Sign](./manop_outsign.md)).
6. **Normalization.** On the subtraction path, the [leading zero detector](./leading_zero_detector.md) and a left-shifter capped at $E_{A_0}-1$ renormalize the result. On the addition path, a carry-out causes a 1-bit right-shift (see [Normalization](./normalization.md)).
7. **Rounding.** The mantissa is rounded to nearest-even, and a rounding carry-out causes one more right-shift and exponent increment (see [Rounding](./rounding.md)).
8. **Output.** The sub-normal exponent adjustment is undone, an overflowed result has its mantissa cleared to form an infinity, and the special-operand override is applied (see [Special Operands](./special_op.md#output-assembly)).

## Conventions
- **Rounding:** round-to-nearest-even only.
- **NaN results:** always the canonical qNaN (sign 0, exponent all ones, mantissa `10…0`).
- **Signed zero:** follows IEEE 754. Exact cancellation gives $+0$, and $(-0)+(-0) = -0$.
- **Exceptions:** no exception-flag outputs (invalid, overflow, underflow, inexact) are produced.
- **Wire names** follow the symbols in the hand-drawn diagram wherever one exists (see [Nomenclature](./nomenclature.md)).
