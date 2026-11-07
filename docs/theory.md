# Theory on Floating-Point Numbers
## General Floating-Point Number Systems

A number $x$ can be represented in general floating-point notation in a general radix-$b$ number as system, as follows:
$$
x = (-1)^S.M.b^E
$$
Where $0 \le M < b^{lm}$, $b$ is the base of the floating-point representation, $M$ is known as the *mantissa* and $E$ is known as the *exponent*, $S$ represents the sign, and is either 0 or 1. The intrinsic integer value of the mantissa can be represented as:
$$
M = \sum_{i = 0}^{lm-1}m_i.b^{i}
$$
However, the mantissa digits are not associated with fixed weights, unlike fixed-point numbers. Their weights are adjusted by the exponent term: $b^E$
$$
\therefore x = (-1)^S.\sum_{i=0}^{lm-1}m_i.b^{E+i}
$$

Hence, the term "floating-point" alludes to the fact that the decimal point separating integer and fractional digits (in base-$b$) is not fixed. As shown, the digits of the mantissa $m_i$ have variable weights $b^{E+i}$, and the magnitude of the leading digit to the left of the floating-point can be moved by adjusting $E$, as:
$$
E = \Big(\sum_{j = 0}^{le-1} e_j.b^j\Big) - (b^{le-1}-1)
$$

Where the extra subtracted term $b^{le-1}-1$ is the *bias*. This scheme trades range for precision. Very large values that would require too many bits in fixed-point schemes can be represented, but at much lesser precision than the corresponding fixed-point representations. 

## Binary Floating-Point Number Systems

For our purposes and in all of computer arithmetic, a radix-2 or a binary number system is considered and the floating-point scheme and its precision can be characterized by the number of mantissa and exponent bits $lm$ and $le$ respectively: (1,$le$,$lm$), where the MSB (1) represents the sign-bit. For a binary floating-point (1,$le$,$lm$) system, a number $x$ can be represented as:
$$
x = M.2^E
$$
This representation is also referred to as a *dyadic rational*.

### Normalization

The leading bit of $M$ cannot be set arbitrarily to 0 or 1. Otherwise, a single value can have multiple representations in the same scheme. For example:
$$
0.25 = 1.0 \times2^{-2} = 0.1\times2^{-1} = 0.01\times2^0=\dots
$$
This ambiguity can be resolved by fixing the leading bit of $M$ to 1 (set). This can be related to the significant digits logic, and that all zero digits to the left of the largest/first non-zero digit, are insignificant, and can be ignored. Since the leading bit now no longer carries unique information about the number, the mantissa bits can be used entirely to represent only the fractional bits to the right of the radix-point. An altered representation of $M$ would be:
$$
M = 1 + \sum_{i=0}^{lm-1}m_i.2^{-i-1}
$$
### Exponent Bias
The exponent field of a floating-point number represents a fixed-point integer as:
$$
E = \sum_{j = 0}^{le-1} e_j.2^j
$$
This would mean that $E$ would represent only positive values in the range of $\Big[0,2^{le}-1\Big]$. This ensures that very large values greater than 1 but only a few values below 1 can be represented, and the latter could only be represented with $E=0$. The smallest non-negative and non-zero value that can be represented, would be $2^{-lm}$, which is small for large $lm$. However, the largest positive value that can be represented would $(2 - 2^{-lm}).2^{2^{le}-1}$. This means that largest value is several orders of magnitude greater than the amount by which 1 is greater than the smallest value. Hence, the range becomes asymmetric, favoring values above 1 and poorly representing values below 1. 

This can be solved by introducing a negative bias $b$:
$$
E = \Big(\sum_{j=0}^{le-1}e_j.2^j\Big) - b \quad \texttt{where} \quad b = 2^{le-1} - 1
$$
This shifts the range of $E$ leftwards to $[-2^{le-1}+1,2^{le-1}]$, which is the most achievable symmetry. Hence, the smallest and largest positive values would be: $2^{-lm}.2^{-2^{le-1}+1}$ and $(2 - 2^{-lm}).2^{2^{le-1}}$.

### Sub-Normal Numbers

Normalization fixes the leading bit of $M$ to 1, which means the smallest positive value representable is $1.0\times2^{E_{min}}$. The spacing between consecutive representable values in that lowest exponent range is $2^{-lm}.2^{E_{min}}$, yet the gap between zero and the smallest normal value is $2^{E_{min}}$ itself, i.e. $2^{lm}$ times larger. The number line therefore has a disproportionately large hole around zero, and the useful property that $x - y = 0 \iff x = y$ is lost, since two distinct nearby values can differ by less than $2^{E_{min}}$ and their difference would have to flush to zero.

This is resolved by reserving the all-zeros exponent field to mean *"the implicit leading bit is 0"*, while holding the effective exponent at $E_{min}$ rather than letting it fall to $-b$. Such numbers are called *sub-normal* (or *denormal*) numbers:
$$
x = (-1)^S.\Big(\sum_{i=0}^{lm-1}m_i.2^{-i-1}\Big).2^{E_{min}} \quad \texttt{where} \quad E_{min} = 1-b
$$

The all-ones exponent field is reserved as well (for the values described in the next two sections), so the exponent field of a *normal* number is restricted to $[1,2^{le}-2]$, and $E$ to $[1-b,b]$. Hence the largest finite value is $(2-2^{-lm}).2^{b}$, the smallest positive normal value is $2^{1-b}$, and the smallest positive sub-normal value is $2^{-lm}.2^{1-b}$.

The significance of holding the exponent at $E_{min}$ instead of $-b$ is that sub-normal numbers inherit the same spacing $2^{-lm}.2^{1-b}$ as the lowest normal range. Precision now degrades one bit at a time as values approach zero, instead of collapsing in a single step. This is referred to as *gradual underflow*. Zero itself is simply the sub-normal with an all-zero mantissa, and since the sign bit remains free, it has two representations: $+0$ and $-0$.

### Infinities

The all-ones exponent field with an all-zero mantissa field represents *infinity*, signed as $\pm\infty$ by the sign bit. It is produced either by an operation on an infinite operand, or by *overflow*, i.e. when the correctly rounded result of an operation on finite operands exceeds the largest finite value in magnitude.

Infinity serves as a saturating end-point that closes the number system under overflow. It preserves ordering ($-\infty < x < +\infty$ for every finite $x$) and allows a computation to continue and report an out-of-range result, rather than wrapping around to an unrelated value as integer arithmetic does.

### NaNs

The all-ones exponent field with a non-zero mantissa field represents *NaN* (*Not a Number*): the result of an operation that has no meaningful value in the reals or in the extended reals, such as $\infty-\infty$, $0\times\infty$, $0/0$ or $\sqrt{-1}$. These are termed *invalid operations*. A NaN is *unordered* with respect to every value including itself, so $\text{NaN} \ne \text{NaN}$, and it *propagates*: any arithmetic operation with a NaN operand returns a NaN, so a single invalid operation remains visible at the end of a long computation instead of being silently absorbed.

The non-zero mantissa field leaves $2^{lm}-1$ distinct patterns per sign, called the *payload*, which is used to distinguish two kinds of NaN:
- *Quiet NaN* (**qNaN**) - the most significant mantissa bit is 1. It propagates through arithmetic without raising any exception, and is the default result delivered by an invalid operation.
- *Signalling NaN* (**sNaN**) - the most significant mantissa bit is 0 (with at least one lower bit set, else the encoding would be an infinity). Using an sNaN as an operand raises the invalid-operation exception and then yields a qNaN. It is intended to mark uninitialized or deliberately poisoned data, so that reading it is detected rather than quietly propagated.
- *Canonical qNaN* - the standard leaves payload propagation implementation-defined, so a NaN-producing operation may return any of the available qNaN encodings. A canonical qNaN is one fixed encoding, namely $S=0$, exponent all-ones and mantissa $10\dots0$, that is emitted for *every* NaN result regardless of the operands' payloads or signs. This makes results bit-reproducible and removes the need to select and forward a payload, at the cost of discarding any diagnostic information the payload carried.

# The Floating-Point Addition Algorithm

Adding two floating-point numbers is not a single arithmetic operation like its fixed-point counterpart. The mantissas can only be added once they share a common exponent, and the sum must then be forced back into the normalized format and rounded to $lm$ fractional bits. The broad steps are:

- Decode both operands and classify them as zero, sub-normal, normal, infinity or NaN.
- Resolve the *effective operation* - whether the magnitudes are to be added or subtracted - from the two sign bits and the requested operation.
- Compare the exponents to find the larger operand and the exponent difference.
- *Align* the two mantissas by right-shifting the one with the smaller exponent by that difference.
- Add or subtract the aligned mantissas.
- *Normalize* the result mantissa back into $[1,2)$ and adjust the exponent by the same amount.
- *Round* the normalized mantissa to $lm$ fractional bits, and re-normalize if rounding overflows.
- Resolve overflow, underflow and special-operand cases, and assemble the final sign, exponent and mantissa.

## Effective Operation and Operand Ordering

For $x \,\square\, y$ where $\square$ is the requested addition or subtraction, let $op$ be 0 for addition and 1 for subtraction. Since the operands carry sign-magnitude signs, what the mantissa datapath actually performs is a subtraction of magnitudes exactly when the two signs and $op$ disagree:
$$
op_{eff} = S_A \oplus S_B \oplus op
$$
Where $op_{eff}=0$ denotes an addition of magnitudes and $op_{eff}=1$ a subtraction.

A mantissa subtraction must not produce a negative value, since the format stores magnitudes only. The operands are therefore ordered, with the larger of the two becoming the minuend. Ordering by exponent alone is sufficient: when the exponents differ, the operand with the larger exponent has the larger magnitude, and when they are equal, a negative difference is corrected by taking its 2's complement and inverting the result sign. The result sign follows the larger operand for a subtraction, and is the common sign of the operands for an addition.

## Alignment

Two values can be added term-by-term only when their mantissa digits carry the same weights. For $E_A \ge E_B$:
$$
M_A.2^{E_A} + M_B.2^{E_B} = \Big(M_A + M_B.2^{-(E_A-E_B)}\Big).2^{E_A}
$$

Hence the smaller operand's mantissa is right-shifted by $d = E_A - E_B$ and the larger exponent $E_A$ is adopted as the tentative result exponent. The shift is the only lossy step before rounding, as it pushes the lowest $d$ bits of $M_B$ past the retained mantissa width. Those bits cannot simply be discarded, because they determine which of the two nearest representable values the exact sum lies closer to.

## Guard, Round and Sticky Bits

It is neither necessary nor possible to retain all $d$ shifted-out bits. Round-to-nearest only needs to know where the discarded tail falls relative to $\frac{1}{2}$ ulp, and three bits appended to the mantissa are sufficient to express that:

- $G$ (*guard*) - the first bit shifted past the retained mantissa.
- $R$ (*round*) - the second such bit.
- $S$ (*sticky*) - the logical OR of every remaining bit shifted out beyond $R$.

Together, $G$ and $R$ give the leading tail bits exactly, while $S$ records only whether anything non-zero remains below them, which is all that is required to distinguish an exact tie from a value just above it. One extra bit would suffice for an addition, but a subtraction can left-shift the result by one position during normalization, and a second bit is needed so that a valid guard bit still exists after that shift.

Since $S$ is monotone - once set it stays set - the alignment shift can be *saturated* at the point where every mantissa bit has been shifted into the sticky region. Beyond that, a larger $d$ changes neither the shifted mantissa nor $G$, $R$ and $S$, so arbitrarily large exponent differences need no wider shifter.

## Mantissa Addition and Subtraction

The aligned mantissas are added or subtracted according to $op_{eff}$, and the two cases behave very differently:

- **Addition.** Both operands lie in $[1,2)$ when normal, so the sum lies in $[2,4)$ and can overflow the mantissa by at most one bit. Normalization is therefore a right-shift by at most 1 with a corresponding increment of the exponent.
- **Subtraction.** The difference lies in $[0,2)$, and when the operands are close it can have an arbitrary number of leading zeros - up to the full mantissa width, in the limiting case of near-total *cancellation*. Normalization then requires a variable left-shift.

Cancellation is the reason the three extra bits matter: a left-shift by $z$ positions pulls $z$ of them back into the significant mantissa, so bits that looked discardable during alignment can become significant again.

## Normalization

Normalization restores the leading-1 invariant and compensates the exponent by the same power of two, keeping the value unchanged:

- A carry out of the mantissa addition is absorbed by a 1-bit right-shift with the exponent incremented by 1. The bit shifted out is merged into $S$.
- Leading zeros after a subtraction are removed by counting them, left-shifting by that count $z$ and decrementing the exponent by $z$.
- The exponent cannot be decremented below $E_{min}$. The left-shift is therefore capped so that a result too small to be normalized stops with the exponent at $E_{min}$ and a leading 0, i.e. encoded as a sub-normal. This is gradual underflow applied to the result.
- If the subtraction cancels exactly, no leading 1 exists at all and the result is zero. Its sign is a matter of convention: under round-to-nearest, IEEE 754 defines the exact cancellation of two unequal-signed terms as $+0$, while an addition of two negative zeros yields $-0$.

## Rounding

The normalized mantissa, still carrying $G$, $R$ and $S$, is rounded to $lm$ fractional bits. Under *round-to-nearest-even*, with $L$ the least significant bit of the retained mantissa, the decision is:
$$
round\_up = G.(R + S + L)
$$

Reading the cases: $G=0$ places the tail below $\frac{1}{2}$ ulp, so the mantissa is truncated. $G=1$ with $R+S=1$ places it above $\frac{1}{2}$ ulp, so the mantissa is incremented. $G=1$ with $R+S=0$ is an exact tie at $\frac{1}{2}$ ulp, and the tie is broken towards the even neighbour, which means incrementing only when $L=1$. The error introduced is therefore at most $\frac{1}{2}$ ulp, and ties do not bias the result in either direction over a long computation, as round-half-up would.

The increment can itself carry out of the mantissa, which happens exactly when every retained bit is 1 and the mantissa wraps from $1.\underbrace{1\dots1}_{lm}$ to $2.\underbrace{0\dots0}_{lm}$. This requires one further right-shift by 1 and one more increment of the exponent. It can occur only once, since the shifted mantissa is then exactly a power of two and cannot round again.

## Exceptional Results

The final step resolves the cases that the mantissa datapath cannot express:

- *Overflow* - if the rounded exponent exceeds $E_{max} = b$, the magnitude is beyond the largest finite value and the result becomes $\pm\infty$, taking the sign the finite result would have had.
- *Underflow* - a result below the smallest normal value is delivered as a sub-normal with reduced precision, and its exponent field is encoded as all-zeros.
- *Special operands* - these override the datapath result entirely. A NaN operand yields a NaN; $\pm\infty$ combined with a finite value yields that same infinity; two infinities yield that infinity when the effective operation is an addition, and a NaN when it is a subtraction, since $\infty-\infty$ is an invalid operation.
- *Signed zero* - $(+0)+(-0) = +0$ and $(-0)+(-0) = -0$ follow from the sign rules, while $x-x = +0$ for finite $x$ follows from the exact-cancellation convention.

# Reference
- [IEEE Standard for Floating-Point Arithmetic](https://drive.google.com/file/d/1d_NoahP3ChJ9Ol-pxoWtLSK2fnfYp0FW/view?usp=sharing) 
