### Test 1
**Date:** 06-03-2026
**File:** [t1](/docs/logs/t1-060326.png)
I generated 32-bit tests vectors for input operands using the C code realtohex. Here were the cases I tested for:
1. 0.1 + 0.2 ->  Expected real result = 0.3, Obtained real result = 0.2375
   
2. 0.5 - 0.5 ->  Expected real result = 0.0, Obtained real result = 0.0 (Currently inspecting)
    <u>Issues</u>
   - Exponent of the result is non-zero. Both number have same exp (exp = 0111 1110b = 7Eh = 126d (biased) = -1 (unbiased)). The mantissa bits are 0 (Only leading 1 after decimal point is significant => 1.0 x 2^(-1) = 0.5)
   - Result exponent is = 0110 0100b = 64h = 100d = -27, still not subnormal. Mantissa bits are all zero =>  result = 1.0 x 2^(-27) which is approx 0
   - Clearly some exponent shifting problem
  
    <u> Observations </u>
   - I was using **reduction NOR** for obtaining leading 1. It should be **reduction OR**. Noticed that mantissa, even after adding leading bit after decimal-point, was showing to be 0.  (***resolved***)
3. Other 3 test vectors were also giving erroneaous results

### Test 2
**Date:** 07-03-2026
**File:** [t2](/docs/logs/t2-070326.png)
Same vectors as previous test, resolved only the reduction NOR to OR for the MSB (one's bit after decimal point)
<u> Observations </u>
1. All test vectors with non-zero expected results are correct (matching perfectly)
2. For zero results, exponent is still non-zero
3. In 2nd vector, a = 0.5, b = 0.5, op = 1(sub), result_exp = 0110_0100b = 64h = 100d = -27d (unbiased)
    Likely cause: Due to this resm_p_encoder outputting isZero=1 and shamt=26. isZero is not being used (***resolved***)

### Test 4
**Date:** 17-03-2026
**File:** [t4](/docs/logs/t4-170326.png)
Test cases were wrongly interpreted. Case of inputs a = 10, b = 80000008, and sub is resulting in the wrong value
Exp_res = cc989680, Res = 4c989680 (MSB is wrong =>  sign-bit error?)
TODO: Recheck output sign logic (***resolved***)

### Test 5
**Date:** 17-03-2026
**File:** [t5](/docs/logs/t4-170326.png)
Erroneous cases:
(a) FAIL: a=00000001 b=00000002 op=0 expected=00000003 got=00800003
(b) FAIL: a=80000001 b=00000001 op=0 expected=00000000 got=80000000
Possible issues:
(a) exp is incremented by 1 for mantissa denormalization at the beginning, must subtract 1 if result exponent is 1 and mantissa does not have leading 1 (result is subnormal)
(b) +0 and -0 error, both are same, must enforce +0 always
TODO: Resolve (a) and (b)
(b) has been resolved (I think). A decrementer is required for (a), in the case where both inputs are sub-normal and the result is also sub-normal