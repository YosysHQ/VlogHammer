
Bug in XSIM when combining reduce op and $signed/$unsigned
==========================================================

~CLOSED~ XSim 2015.1

The following module should return **3'b001**:

    :::Verilog
    module issue_017(y);
      output [2:0] y;
      assign y = &($signed(2'b11));
      initial #10 $display("%b", y);
    endmodule

But xsim 2013.4 returns **3'b000** instead.

I get the the same bug when I replace **$signed** with **$unsigned**. The bug goes away
if I do not use **$signed** or **$unsigned** or reduce the size of **y**. Somehow the
size of **y** "leaks through" to the self-determined operand of the **&** reduce operator
when used with **$signed** or **$unsigned**.

In my tests I have run this module with:

    xvlog issue_017.v
    xelab -R work.issue_017

Crosscheck: Vivado 2013.4, XST 14.7, Quartus 13.1 and Modelsim 10.1d implement
this correctly.

**History:**  
2014-01-25 [Reported](http://forums.xilinx.com/t5/Simulation-and-Verification/Bug-in-XSIM-when-combining-reduce-op-and-signed-unsigned/td-p/406801) bug in Xilinx Support Forum  
2014-04-16 [Still broken in XSim 2014.1](http://forums.xilinx.com/t5/Synthesis/Bugs-in-Vivado-2014-1/td-p/440750)  
2015-05-15 Fixed in XSim 2015.1  
