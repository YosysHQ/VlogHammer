
Incorrect results with XNOR/shift expression
============================================

~CLOSED~ Verilator GIT e8edbad

This should always return `y=4'b1111`, but Verilator f705f9b only does this for `a=0`:

    :::Verilog
    module issue_053(a, y);
      input [3:0] a;
      output [3:0] y;
      assign y = (a >> a) ^~ (a >> a);
    endmodule

Self-contained test case:
[test019.v](http://svn.clifford.at/handicraft/2014/verilatortest/test019.v),
[test019.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test019.cc),
[test019.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test019.sh)

**History:**  
2014-05-25 Reported as [Issue #776](http://www.veripool.org/issues/776-Verilator-Incorrect-results-with-XNOR-shift-expression)  
2014-09-25 Fixed in GIT commit e8edbad  
