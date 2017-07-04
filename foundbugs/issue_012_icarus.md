
Icarus Verilog undef propagation bug in power operator
======================================================

~CLOSED~ Icarus GIT 68f8de2

icarus verilog (git d1c9dd5) does not correctly propagate undef through the power
operator. For example, **y** should be **4'bx** when a is zero in the following test
case, but iverilog returns **4'd1**:

    :::Verilog
    module issue_012(a, y);
      input [3:0] a;
      output [3:0] y;
      assign y = 4'd2 ** (4'd1/a);
    endmodule

**History:**  
2014-01-06 [Reported](https://github.com/steveicarus/iverilog/issues/7) bug on GitHub  
2014-02-15 Fixed in GIT commit [68f8de2](https://github.com/steveicarus/iverilog/commit/68f8de28afc4a5d559742d7c8189bff97e6568bf)  
