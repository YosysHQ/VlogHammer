
Verilator bug with signedness and arithmetic shift
==================================================

~CLOSED~ Verilator GIT a985a1f

Verilator b631b59 returns **1** instead of **0** for **a=-1** and **b=7**:

    :::Verilog
    module issue_037(a, b, y);
      input signed [4:0] a;
      input [2:0] b;
      output [3:0] y;
      assign y = |0 != (a >>> b);
    endmodule

Self-contained test case:
[test008.v](http://svn.clifford.at/handicraft/2014/verilatortest/test008.v),
[test008.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test008.cc),
[test008.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test008.sh)

Verilog testbench for comparison:
[test008_tb.v](http://svn.clifford.at/handicraft/2014/verilatortest/test008_tb.v)

**History:**  
2014-05-01 Reported as [Issue #756](http://www.veripool.org/issues/756-Verilator-Verilator-bug-with-signedness-and-arithmetic-shift)  
2014-05-03 Fixed in GIT commit a985a1f  
