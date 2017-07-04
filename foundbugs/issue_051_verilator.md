
Another Verilotor bug with large shifts
=======================================

~CLOSED~ Verilator GIT e8edbad

For a=5, b=35 this should return y=0, but Verilator f705f9b returns y=8 instead:

    :::Verilog
    module issue_051(a, b, y);
      input [3:0] a;
      input [5:0] b;
      output [3:0] y;
      assign y = 64'd0 | (a << b);
    endmodule

Self-contained test case:
[test018.v](http://svn.clifford.at/handicraft/2014/verilatortest/test018.v),
[test018.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test018.cc),
[test018.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test018.sh)

**History:**  
2014-05-24 Reported as [Issue #774](http://www.veripool.org/issues/774-Verilator-Another-Verilotor-bug-with-large-shifts)  
2014-09-25 Fixed in GIT commit e8edbad  
