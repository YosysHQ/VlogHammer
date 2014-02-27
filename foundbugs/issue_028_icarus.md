
Icarus does undef propagation of const multiplies incorrectly
=============================================================

~OPEN~ Icarus GIT a3450bf

The following module should set the output to constant **4'bxxxx**:

    :::Verilog
    module test(y);
      output [3:0] y;
      assign y = 4'b0 * 4'bx;
    endmodule

But Icarus Verilog (git a3450bf) is too smart and outputs **4'b0000** instead.

**History:**  
2014-02-27 [Reported](https://github.com/steveicarus/iverilog/issues/18) bug on GitHub  

