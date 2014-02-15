
Icarus Verilog: internal error: lval-rval width mismatch
========================================================

~OPEN~ Icarus GIT 68f8de2

The following module fails to build with icarus verilog (git 68f8de2):

    :::Verilog
    module issue_022(a, y);
      input [1:0] a;
      output [1:0] y;
      assign y = 'bx ? 2'b0 : a;
    endmodule

the error message produced is:

    internal error: lval-rval width mismatch: rval->vector_width()==1, lval->vector_width()==2
    assert: elaborate.cc:150: failed assertion rval->vector_width() >= lval->vector_width()

**History:**  
2014-02-15 [Reported](https://github.com/steveicarus/iverilog/issues/12) bug on GitHub  

