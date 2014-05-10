
Bug in evaluating (defined) expression with undef bits
======================================================

~OPEN~ Verilator GIT 6ce2a52

This should set y=1, but verilator 6ce2a52 sets y=0 instead.

    :::Verilog
    module issue_042(y);
      output [3:0] y;
      localparam [3:0] p11 = 1'bx;
      assign y = ~&p11;
    endmodule

Self-contained test case:
[test013.v](http://svn.clifford.at/handicraft/2014/verilatortest/test013.v),
[test013.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test013.cc),
[test013.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test013.sh)

**History:**  
2014-05-11 Reported as [Issue #764](http://www.veripool.org/issues/764-Verilator-Bug-in-evaluating-defined-expression-with-undef-bits)
