
Icarus Verilog bug in processing "1'b1 >= |1'bx"
================================================

~CLOSED~ Icarus GIT 5a06602

The following module should set y to **1'bx**. But Icarus Verilog (git b1ef099)
sets the output to **1'b1**.

    :::Verilog
    module issue_024(y);
      output y;
      assign y = 1'b1 >= |1'bx;
    endmodule

**History:**  
2014-02-17 [Reported](https://github.com/steveicarus/iverilog/issues/14) bug on GitHub  
2014-02-16 Fixed in GIT commit [5a06602](https://github.com/steveicarus/iverilog/commit/5a06602af2a0c4087ecc99f16ebc5e0d67f78dcd)  
