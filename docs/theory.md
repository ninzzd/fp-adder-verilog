# Theory on Floating-Point Numbers
## General Floating-Point Number Systems

A number $x$ can be represented in general floating-point notation in a general radix-$b$ number as system, as follows:
$$
x = (-1)^S.M.b^E
$$
Where $0 \le M < b$, $b$ is the base of the floating-point representation, $M$ is known as the *mantissa* and $E$ is known as the *exponent*, $S$ represents the sign, and is either 0 or 1. The intrinsic value of the mantissa can be represented as:
$$
M = \sum_{i = 0}^{lm-1}m_i.b^{-i}
$$
However, the mantissa digits are not associated with fixed weights, unlike fixed-point numbers. Their weights are adjusted by the exponent term: $b^E$
$$
\therefore x = (-1)^S.\sum_{i=0}^{lm-1}m_i.b^{E-i}
$$

Hence, the term "floating-point" alludes to the fact that the decimal point separating integer and fractional digits (in base-$b$) is not fixed. As shown, the digits of the mantissa $m_i$ have variable weights $b^{E-i}$, and the magnitude of the leading digit to the left of the floating-point can be moved by adjusting $E$, as:
$$
E = \Big(\sum_{j = 0}^{le-1} e_i.b^i\Big) - (b^{le-1}-1)
$$

Where the extra subtracted term $b^{le-1}-1$ is the *bias*. This scheme trades range for precision. Very large values that would require too many bits in fixed-point schemes can be represented, but at much lesser precision than the corresponding fixed-point representations. 

## Binary Floating-Point Number Systems

For our purposes and in all of computer arithmetic, a radix-2 or a binary number system is considered and the floating-point scheme and its precision can be characterized by the number of mantissa and exponent bits $lm$ and $le$ respectively: (1,$le$,$lm$), where the MSB (1) represents the sign-bit. For a binary floating-point (1,$lm$,$le$) system, a number $x$ can be represented as:
$$
x = M.2^E
$$

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
This shifts the range of $E$ leftwards to $[-2^{le-1}+1,2^{le-1}]$, which is the most achievable symmetry. Hence, the largest and smallest positive values would be: $2^{-lm}.2^{-2^{le-1}+1}$ and $(2 - 2^{-lm}).2^{2^{le-1}}$.

### Sub-Normal Numbers


# Reference
- [IEEE Standard for Floating-Point Arithmetic](https://drive.google.com/file/d/1d_NoahP3ChJ9Ol-pxoWtLSK2fnfYp0FW/view?usp=sharing) 
