
Icarus Verilog signedness handling in binary bitwise operations of constants
============================================================================

~CLOSED~ Icarus GIT ac3aee0

Bitwise operations of signed values should yield a signed value (see sec. 5.5.1
of IEEE Std 1365-2005). This is implemented correctly in Icarus Verilog for
operations involving at least one variable, but bit-wise boolean operations of
two signed constants yield an unsigned constant.

For example the following test case:

    :::Verilog
    module issue_013(a, y);
      input signed [3:0] a;
      output [1:0] y;
      assign y[0] = a > (4'sb1010 | 4'sd0);
      assign y[1] = (a | 4'sd0) > 4'sb1010;
    endmodule

For **a=0** this will assign **[0]=0** and **[1]=1**. The value for **y[1]** is
correct (this is an all-signed expression). The value for **y[0]** is
incorrect. (Tested with git d1c9dd5.)

**History:**  
2014-01-06 [Reported](https://github.com/steveicarus/iverilog/issues/8) bug on GitHub  
2014-02-15 Fixed in GIT commit [ac3aee0](https://github.com/steveicarus/iverilog/commit/ac3aee01720773002f995b9185d2e2024e736177)  
