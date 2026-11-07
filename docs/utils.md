# Utility Blocks
**File(s)**: [`add`][add], [`inc`][inc], [`dec`][dec], [`min`][min], [`mux`][mux], [`bitmux`][bitmux], [`p_encoder`][p_encoder]
## Purpose
- To provide the generic, parameterized building blocks that the datapath is assembled from. All arithmetic and comparisons in the datapath go through these modules instead of behavioural `+`, `-` and `<` operators, so that the RTL keeps matching the [microarchitectural diagram](../README.md#architecture) block for block.

## Architectural Decisions
### `add` - Carry-Lookahead Adder
- A `W`-bit adder with carry-in and carry-out. Each carry is computed directly from the generate and propagate terms of all lower bit positions, instead of rippling:
$$
g_i = a_i.b_i, \quad p_i = a_i + b_i
$$
$$
c_i = \sum_{k=0}^{i} \Big(g_{i-k}.\prod_{j=i-k+1}^{i} p_j\Big) + \Big(\prod_{j=0}^{i}p_j\Big).c_{in}
$$
- The sum bits are $s_i = a_i \oplus b_i \oplus c_{i-1}$, with $c_{-1} = c_{in}$. The OR-form of the propagate term is valid here because it is only used for carries, never for the sum.
- **Subtraction** is performed as $a + \overline{b} + 1$: the subtrahend is inverted and `cin = 1`. The carry-out is then 1 exactly when $a \ge b$, which is how the datapath compares values (see [Exponent Comparator](./exponent_comparator.md)).
- The tradeoff is a short, fixed-depth carry path at the cost of area: the number of terms in $c_i$ grows with $i$, so the total size grows roughly with $W^2$. Swapping in other adder architectures (Brent-Kung, Kogge-Stone, ripple-carry, etc.) is left as a future option.

### `inc` - Incrementer
- Adds the single bit `cin` to `in`. Bit `i` flips exactly when `cin` is set and every lower bit is 1:
$$
out_i = in_i \oplus \Big(c_{in}.\prod_{j=0}^{i-1}in_j\Big), \quad c_{out} = c_{in}.\prod_{j=0}^{W-1}in_j
$$
- Each bit computes its own reduction-AND, so there is no ripple through half-adders. (An earlier ripple-carry version was replaced for this reason.)
- It is used wherever only a conditional `+1` is needed: the sub-normal exponent adjustment, the conditional 2's complement (inverting XOR followed by `inc`), the exponent increments on carry-out, and the rounding increment.

### `dec` - Decrementer
- Subtracts 1 from `in`, with no borrow-in. Bit `i` flips exactly when every lower bit is 0:
$$
out_0 = \overline{in_0}, \quad out_i = \overline{in_i} \oplus \Big(\sum_{j=0}^{i-1}in_j\Big)
$$
- It is only used to compute $E_{A_0} - 1$ for the [normalization](./normalization.md#subtraction-path-capped-left-shift) shift cap. Since $E_{A_0} \ge 1$ after the sub-normal adjustment, it never underflows, and no borrow-out is provided.

### `min` - Minimum Selector
- Outputs the smaller of `a` and `b`. It computes only the carry-out of $a + \overline{b} + 1$, using the same lookahead form as `add` but without any sum bits, and uses it to drive a 2:1 mux:
    - carry-out = 1 ($a \ge b$) $\rightarrow$ `b`
    - carry-out = 0 ($a < b$) $\rightarrow$ `a`
- It is used to clip shift amounts: the alignment shift to `lm+3` (see [Mantissa Alignment](./mantissa_alignment.md#shift-amount-clipping)) and the renormalization shift to $E_{A_0}-1$. In both cases the comparison is made at the full `le`-bit width, and only the clipped result is truncated afterwards.

    (*Check out [Test 6](./logs/running_doc.md#test-6), where the truncation was done before the comparison*)

### `mux` and `bitmux` - Multiplexers
- `bitmux` is an `N`:1 single-bit mux written as a sum of minterms (Shannon expansion). Each minterm is a reduction-AND of the bitwise XNOR of `sel` and the constant `i`, i.e. $m_i = (sel = i)$:
$$
out = \sum_{i=0}^{N-1} in_i.m_i
$$
- `mux` is a `W`-bit, `N`:1 mux built from `W` instances of `bitmux`. Its `N` inputs are packed into one bus, with input `j` at `in[j*W +: W]`, so `{in_1, in_0}` selects `in_0` when `sel = 0`.
- The select port is `$clog2(N)` bits wide. A select value of `N` or more (possible when `N` is not a power of 2) matches no minterm, so the output is 0.
- Every caller must truncate its select to exactly `$clog2(N)` bits for the actual mux size `N`. Getting this width wrong has been the most frequent source of bugs in this design.

    (*Check out [Test 13](./logs/running_doc.md#test-13), where the shifter muxes were sized for `lm+1` inputs instead of `lm+4`*)

### `p_encoder` - Priority Encoder
- A general `N`:1 priority encoder with a programmable output function. It is described together with its only user in [Leading Zero Detector](./leading_zero_detector.md#priority-encoder).

[add]: ../rtl/utils/add.v
[inc]: ../rtl/utils/inc.v
[dec]: ../rtl/utils/dec.v
[min]: ../rtl/utils/min.v
[mux]: ../rtl/utils/mux.v
[bitmux]: ../rtl/utils/bitmux.v
[p_encoder]: ../rtl/utils/p_encoder.v
