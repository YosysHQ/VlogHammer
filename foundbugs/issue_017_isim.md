
Bug in ISIM when combining reduce op and $signed/$unsigned
==========================================================

~WONTFIX~ Isim 14.7

The following module should return **3'b001**:

    :::Verilog
    module issue_017(y);
      output [2:0] y;
      assign y = &($signed(2'b11));
      initial #10 $display("%b", y);
    endmodule

But isim 14.7 returns **3'b000** instead.

I get the the same bug when I replace **$signed** with **$unsigned**. The bug goes away
if I do not use **$signed** or **$unsigned** or reduce the size of **y**. Somehow the
size of **y** "leaks through" to the self-determined operand of the **&** reduce operator
when used with **$signed** or **$unsigned**.

In my tests I have run this module with:

    vlogcomp issue_017.v
    fuse -o issue_017 issue_017

    ./issue_017
    ISim> run all

Crosscheck: Vivado 2013.4, XST 14.7, Quartus 13.1 and Modelsim 10.1d implement
this correctly.

**History:**  
2014-01-23 [Reported](http://forums.xilinx.com/t5/Simulation-and-Verification/Bug-in-ISIM-when-combining-reduce-op-and-signed-unsigned/td-p/406305) bug in Xilinx Support Forum
2014-01-24 WONTFIX-Notice from Xilinx

