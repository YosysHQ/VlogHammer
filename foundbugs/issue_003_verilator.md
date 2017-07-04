
Verilator bug with shift, expression width and signedness
=========================================================

~CLOSED~ Verilator GIT b631b59

Verilator adb39ce seems to have troubles with the following expressions. It seems
to correctly interpret **-2'sd1** as the value 3, but then has problems identifying the
correct bit width for the expression and sign extends it even though the result
of **<<** should be unsigned.

    :::Verilog
    module issue_003(a, y);
      input signed [3:0] a;
      output [4:0] y;
      assign y = a << -2'sd1;
    endmodule

Crosscheck: Vivado 2013.4, XST 14.7, Xsim 2013.4 and Modelsim 10.1d implement
this correctly.

Self-contained test case:
[test007.v](http://svn.clifford.at/handicraft/2014/verilatortest/test007.v),
[test007.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test007.cc),
[test007.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test007.sh)

Verilog testbench for comparison:
[test007_tb.v](http://svn.clifford.at/handicraft/2014/verilatortest/test007_tb.v)

**History:**  
2014-04-30 Reported as [Issue #754](http://www.veripool.org/issues/754-Verilator-Verilator-bug-with-shift-expression-width-and-signedness)  
2014-04-30 Fixed in GIT commit b631b59  
