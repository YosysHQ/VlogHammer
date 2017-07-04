
Verilator bug in sign extending special boolean expression
==========================================================

~CLOSED~ Verilator GIT 06744b6

This should set y=4'b1111 but Verilator d7e4bc1 sets y=4'b0001 instead.

    :::Verilog
    module issue_046(a, y);
      input signed [3:0] a;
      output [3:0] y;
      assign y = $signed(5'd1 > a-a);
    endmodule

Only slight modifications in the expression make the problem disappear.

Self-contained test case:
[test015.v](http://svn.clifford.at/handicraft/2014/verilatortest/test015.v),
[test015.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test015.cc),
[test015.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test015.sh)

**History:**  
2014-05-15 Reported as [Issue #768](http://www.veripool.org/issues/768-Verilator-Verilator-bug-in-sign-extending-special-boolean-expression)  
2014-05-16 Fixed in GIT commit 06744b6  
