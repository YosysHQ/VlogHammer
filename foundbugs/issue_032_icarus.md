
Icarus confused about signed/unsigned in strange ?: example
===========================================================

~CLOSED~ Icarus GIT bc9382e

The following module should set the output to constant **0**, because
the **4'b0** makes the whole expression unsigned.

    :::Verilog
    module issue_032(y);
      wire signed [3:0] a = -5;
      wire signed [3:0] b =  0;
      output y;
      assign y = (1 ? a : 4'b0) < (1 ? b : b); 
      initial #1 $display("%b", y);
    endmodule

But Icarus Verilog (git 3e41a93) assigns **1** instead. Interestingly
the bug goes away if the **(1 ? b : b)** is replaced by **b**.

**History:**  
2014-03-06 [Reported](https://github.com/steveicarus/iverilog/issues/20) bug on GitHub  
2014-03-06 Fixed in GIT commit [bc9382e](https://github.com/steveicarus/iverilog/commit/bc9382eea39b65119c5496a54675d55a1162416d)  
