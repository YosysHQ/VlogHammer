
Icarus does undef propagation of const multiplies incorrectly
=============================================================

~CLOSED~ Icarus GIT ed2e339

The following module should set the output to constant **4'bxxxx**:

    :::Verilog
    module test(y);
      output [3:0] y;
      assign y = 4'b0 * 4'bx;
    endmodule

But Icarus Verilog (git a3450bf) is too smart and outputs **4'b0000** instead.

**History:**  
2014-02-27 [Reported](https://github.com/steveicarus/iverilog/issues/18) bug on GitHub  
2014-02-25 Fixed in GIT commit [ed2e339](https://github.com/steveicarus/iverilog/commit/ed2e339dd6ea366864969cbd929325e117ec23e9)  
