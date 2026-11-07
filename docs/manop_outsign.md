# Mantissa Adder Operation Logic and Output Sign
**File(s)** - [`add`](../rtl/utils/add.v), [`fpadd.v`](../rtl/fpadd.v)
## Purpose
- To facilitate the addition or subtraction of `lm+le+1`-bit floating-point numbers, with each input operand being positive or negative.
- To determine the sign of the output.
## Architectural Decisions
### Adder
- The `add.v` file constructs an **`N`-bit CLA** using `generate` loops.
- The operand with the lower exponent ($B_0$ in the file) has a mantissa of `lm+1` bits (including the implicit leading bit), which is extended to `lm+4` after mantissa alignment which generates 3 rounding bits. The other mantissa (that of $A_0$) contains only `lm+1` bits, and only requires least-significant zero-padding: `{a0m, 3'b000}`.
- The adder instantiated in `fpadd.v` is a `lm+4`-bit CLA (see [Utility Blocks](./utils.md#add---carry-lookahead-adder)).
- By default, the mantissa of $B_0$ is passed to the inverting-XOR block for generating its 1's complement based on bit `maddop`. The adder's carry-in is also `maddop`, which turns the 1's complement into a 2's complement, so the adder computes $A_0 - B_0$ when `maddop = 1`.
- The carry-out bit of the adder is represented as $M_{ADD_{c}}$ in the [diagram](../README.md#architecture) and as `maddcout` in the file.
- The adder result `maddres` is passed through a 2s complement module which is triggered by a wire `flag`. The floating-point number can have a sign, but its mantissa must always be positive, hence the following logic:
```
    If op is sub (maddop = 1):
        If maddcout = 0 (negative result mantissa):
            flag = 1 (take 2s complement)
        Else:
            flag = 0 (keep as it is)
    Else:
        flag = 0 (add, mantissa is always positive)
```
- This implies : `flag = maddop&~maddcout`
- `flag` can only be set when both operands have the same exponent. With different exponents, $A_0$ always has the larger magnitude, so $A_0 - B_0$ cannot be negative.
- The 2's complement is built from an inverting-XOR block and an `inc` with carry-in `flag`, giving the magnitude `maddres_2s`.

### Operation and Output Sign
- The operation add/sub is denoted by the signal (denoted as $M_{ADD_{op}}$ in the [diagram](../README.md#architecture)) `maddop` such that:
    - `maddop = 0` $\rightarrow$ add
    - `maddop = 1` $\rightarrow$ sub
- The addition/subtraction expression is adjusted such that the CLA **always considers the mantissa of $A_0$ as positive**, with `maddop` being adjusted accordingly. `flag` normalizes the sign in case of mantissa subtraction, which is then complemented if $A_0$ was initially negative (shown in the truth table, with a negative sign outside the brackets for the simplified expression).
- `maddop` and output sign $S_c$ can be determined by the following truth table
Let $A_0$ and $B_0$ be the absolute values of the operands, with $A_0$ having a larger exponent than $B_0$.

| $S_{A_0}$ | $op$ | $S_{B_0}$ | Expression |  $M_{ADD_{op}}$ | $S_c$| 
| :---: | :---: | :---: | :---: | :---: | :---: |
|  0    |  0   |   0     |   $(A_0)+(+B_0) = +(A_0+B_0)$ |  0   |  0   |
|  0    |  0   |   1     |   $(A_0)+(-B_0) = +(A_0-B_0)$    |  1   |  0 $\oplus$ `flag`   |
|  0    |  1   |   0     |   $(A_0)-(+B_0) = +(A_0-B_0)$    |  1   |  0 $\oplus$ `flag`   |
|  0    |  1   |   1     |   $(A_0)-(-B_0) = +(A_0+B_0)$    |  0   |  0   |
|  1    |  0   |   0     |   $(-A_0)+(+B_0) = -(A_0-B_0)$    |  1   |  1 $\oplus$ `flag`    |
|  1    |  0   |   1     |   $(-A_0)+(-B_0) = -(A_0+B_0)$    |  0   |  1   |
|  1    |  1   |   0     |   $(-A_0)-(+B_0) = -(A_0+B_0)$    |  0   |  1   |
|  1    |  1   |   1     |   $(-A_0)-(-B_0) = -(A_0-B_0)$    |  1   |  1$\oplus$ `flag`    |

- Hence: `maddop = sa0 ^ sb0 ^ op = sa ^ sb ^ op` and `sc = sa0 ^ flag` , where `sa` and `sb` are the signs of the input operands `a` and `b`, respectively. `sa0` and `sb0` are signs of swapped operands based on exponent comparison
- `maddop` is symmetric in the two signs, so it can be computed directly from `a` and `b` before the swap.
- The table assumes the expression is $A_0 \; op \; B_0$, which holds only when `a` is $A_0$ (`ageb = 1`). When `b` has the larger exponent (`ageb = 0`) and the operation is a subtraction, the expression is really $B_0 - A_0$, so the sign of the $A_0$ term must be inverted:
```verilog
sc = sa0 ^ flag ^ (op & ~ageb)
```
(*Check out [Test 4](./logs/running_doc.md#test-4), where this inversion was missing*)

### Handling Zero Result
- A zero result is obtained either by exact cancellation (equal magnitudes with `maddop = 1`), or by adding two zeros with `maddop = 0`. IEEE 754 defines the sign of both cases under round-to-nearest:
    - **Effective subtraction** (`maddop = 1`): the result is always $+0$. For example $(+a)-(+a)$, $(-a)+(+a)$, $(-0)+(+0)$ and $(+0)-(+0)$ all give $+0$.
    - **Effective addition** (`maddop = 0`): the result keeps the common sign of the operands. For example $(-0)+(-0) = -0$ and $(-0)-(+0) = -0$.
- With equal magnitudes, `ageb = 1` and `maddcout = 1` (since $2^n + a - a = 2^n$), so `flag = 0` and the expression above reduces to `sc = sa0`. This is already correct for effective addition, but gives $-0$ for a cancellation with negative $A_0$.
- Hence the sign is forced to 0 only for an exactly-zero result of an effective subtraction (`maddres_isZero` is obtained from the priority encoder that checks for leading zeros, see [Leading Zero Detector](./leading_zero_detector.md)):
```verilog
assign res_sign = (a0s ^ flag ^ (op&~ageb)) & ~(maddop & maddres_isZero);
```
(*Check out [Test 5](./logs/running_doc.md#test-5), [Test 10](./logs/running_doc.md#test-10) and [Test 14](./logs/running_doc.md#test-14), where this gating went from always forcing $+0$, to never forcing it, to the IEEE rule above*)

## Architectural Diagram
Refer to the mantissa adder (`A`, `B`, `op`, `C`, `S` block), the *2's Complement* block with its `flag` input, and the XOR gates producing $MADD_{op}$ and $S_c$ in the [microarchitectural diagram](../README.md#architecture).
