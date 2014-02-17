
Icarus Verilog bug in processing "1'b1 >= |1'bx"
================================================

~OPEN~ Icarus GIT b1ef099

The following module should set y to **1'bx**. But Icarus Verilog (git b1ef099)
sets the output to **1'b1**.

    :::Verilog
    module issue_024(y);
      output y;
      assign y = 1'b1 >= |1'bx;
    endmodule

**History:**  
2014-02-17 [Reported](https://github.com/steveicarus/iverilog/issues/14) bug on GitHub  

