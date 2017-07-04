
XSim fails to recognize signed expression with shift in localparam
==================================================================

~CLOSED~ XSim 2014.1

The following module should return **4'b1110** but instead returns **4'b0110**
with xsim 2013.4:

    :::Verilog
    module issue_020(y);
      output [3:0] y;
      localparam [3:0] p = 3'sb100 >>> 2'b01;
      assign y = p;
      initial #10 $display("%b", y);
    endmodule

XSim 2013.4 seems to think that the expression for **p** is unsigned because
the 2nd operand to the shift operator is unsigned. But sec. 5.1.12 of IEEE Std
1364-2005 states that the right operand of a shift operation has no effect on
the signedness of the result.

In my tests I have run this module with:

    xvlog issue_020.v
    xelab -R work.issue_020

Crosscheck: Vivado 2013.4, XST 14.7, Quartus 13.1 and Modelsim 10.1d implement
this correctly.

Isim 14.7 incorrectly returns **4'b0010** for the same test case.

**History:**  
2014-01-24 [Reported](http://forums.xilinx.com/t5/Simulation-and-Verification/XSim-fails-to-recognize-signed-expression-with-shift-in/td-p/406617) bug in Xilinx Support Forum  
2014-04-16 Fixed in XSim 2014.1  
