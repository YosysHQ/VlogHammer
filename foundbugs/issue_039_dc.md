
Design Compiler refuses input with ELAB-922 error
=================================================

~WONTFIX~ DC G-2012.06-SP4

DC G-2012.06-SP4 refuses to elaborate the following module with an
ELAB-922 (Constant value required) error message:

    :::Verilog
    module issue_039(a, y);
      input [3:0] a;
      output [3:0] y;
      assign y = a >>> 4'bx;
    endmodule

But other expression that evaluate to `4'bx` (such as `a + 4'bx) are accepted.

A script that triggers this error can be found here:  
[http://svn.clifford.at/handicraft/2014/vlogdctests/test003.sh](http://svn.clifford.at/handicraft/2014/vlogdctests/test003.sh)

Crosscheck: Vivado 2014.4, Quartus II 13.1, XST 14.7, Verific 35_463_32_140306,
XSim 2014.4, Modelsim 10.1d, Iacrus GIT 6547fde and Verilator GIT f705f9b
accept this input.

**History:**  
2014-05-26 Formulated original bug report  
