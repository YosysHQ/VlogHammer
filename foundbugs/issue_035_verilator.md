
Verilator bug in signed/unsigned expression eval
================================================

~CLOSED~ Verilator GIT adb39ce

The term **(p1 + p2)** below is part of an unsigned expression and thus should
be zero-extended. Verilator fb4928b however performs signed bit extension
and thus returns an incorrect result.

    :::Verilog
    module issue_035(a, y);
      input [3:0] a;
      output [5:0] y;

      localparam signed [3:0] p1 = 4'b1000;
      localparam signed [3:0] p2 = 0;
      assign y = a + (p1 + p2);
    endmodule

Crosscheck: Vivado 2013.4, XST 14.7, Quartus 13.1, Xsim 2013.4 and Modelsim
10.1d implement this correctly.

Self-contained test case:
[test006.v](http://svn.clifford.at/handicraft/2014/verilatortest/test006.v),
[test006.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test006.cc),
[test006.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test006.sh)

**History:**  
2014-04-09 Reported as [Issue #737](http://www.veripool.org/issues/737-Verilator-Verilator-bug-in-signed-unsigned-expression-eval)  
2014-04-30 Fixed in GIT commit adb39ce  
