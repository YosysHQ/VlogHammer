
Incorrect results with partially out-of-bounds part select
==========================================================

~OPEN~ Verilator 3_906

This should return `y=4'b100x` for `a=1`, but verilator returns `y=0` instead
(the MSB should be '1', obviously we don't care about the 'x' in the LSB that
is the result of the (by one bit) out-of-bounds part select):

    :::Verilog
    module issue_057(a, y);
      input [2:0] a;
      output [3:0] y;
      localparam [5:15] p = 51681708;
      assign y = p[15 + a -: 5];
    endmodule

Self-contained test case:
[test020.v](http://svn.clifford.at/handicraft/2014/verilatortest/test020.v),
[test020_tb.v](http://svn.clifford.at/handicraft/2014/verilatortest/test020_tb.v),
[test020.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test020.cc),
[test020.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test020.sh)

This is with git e8edbad (verilator_3_864).

**History:**  
2014-09-23 Reported as [Issue #823](http://www.veripool.org/issues/823-Verilator-Incorrect-results-with-partially-out-of-bounds-part-select)  
2017-07-01 Still broken in Verilator GIT 1da5a33 (3_906)  
