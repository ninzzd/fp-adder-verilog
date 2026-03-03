# Theory on Floating-Point Numbers
A major drawback of fixed-point numbers is the lack of range, i.e fixed-point numbers have fixed precision due ot the fixed bit weights but the highest and lowest weights are limited. To store very large or very small numbers, too many bits would be required in the case of fixed-point representations, and the intermediate bits barely influence the magnitude of the number. In a way, the fixed-point numbers provide fine details at every range, which is unnecessary. Floating-point numbers solve this issue by storing only a fixed number of precision bits (mantissa) around a given value of the exponent. A floating-point binary number can be represented in the following the manner:
```math
A = M_A . 2^{E_A}
```
## Mantissa Normalization
Where $M_A$ is the mantissa and $E_A$ is the exponent. Any given number can have infinite floating-point representations as $M_A$ can have any number of leading zeros after the first significant/set bit. The IEEE 754 standard fixes this issue by a process of **normalization**, where in $E_A$ is adjusted to let $M_A$ have a range of $(2^{E_A},2^{E_A+1})$, which is possible by setting the bit after the decimal-point to be 1, i.e. 
```math
    M_A = 1.(x_{lm-1})(x_{lm-2})...(x_{0})
```
where $lm$ represents the number of mantissa bits. 
## Sub-normal Numbers

## Exponent Biasing

# Hardware Implementation
## Exponent Comparator
## Right-Shifter for Lower Mantissa
## Result Mantissa Priority Encoder
## Result Mantissa Left Shifter
# Utility Hardware