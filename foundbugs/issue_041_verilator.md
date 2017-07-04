
Yet another Verilator shift bug
===============================

~CLOSED~ Verilator GIT 6ce2a52

This should effectively be y=0, but verilator 1f56312 evaluates y=a instead.

    :::Verilog
    module issue_041(a, y);
      input [2:0] a;
      output [3:0] y;
      assign y = (a >> 2'b11) >> 1;
    endmodule

Self-contained test case:
[test012.v](http://svn.clifford.at/handicraft/2014/verilatortest/test012.v),
[test012.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test012.cc),
[test012.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test012.sh)

**History:**  
2014-05-10 Reported as [Issue #763](http://www.veripool.org/issues/763-Verilator-Yet-another-Verilator-shift-bug)  
2014-05-11 Fixed in GIT commit 6ce2a52  
