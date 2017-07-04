
Verilator returns incorrect expression result
=============================================

~CLOSED~ Verilator GIT f705f9b

This should return `y=0` for `a=31`, but Verilator 06744b6 returns `y=31` instead:

    :::Verilog
    module issue_050(a, y);
      input [4:0] a;
      output [4:0] y;
      assign y = a >> ((a ? 1 : 2) << a);
    endmodule

Self-contained test case:
[test017.v](http://svn.clifford.at/handicraft/2014/verilatortest/test017.v),
[test017.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test017.cc),
[test017.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test017.sh)

**History:**  
2014-05-23 Reported as [Issue #773](http://www.veripool.org/issues/773-Verilator-Verilator-returns-incorrect-expression-result)  
2014-05-24 Fixed in GIT commit f705f9b  
