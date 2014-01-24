
ISIM handling width of localparam incorrectly
=============================================

~WONTFIX~ Isim 14.7

The following module should return **4'b1110**:

    :::Verilog
    module issue_018(y);
      output [3:0] y;
      localparam [3:0] p = ~1'b1;
      assign y = p;
      initial #10 $display("%b", y);
    endmodule

But isim 14.7 returns **4'b0000** instead.

Like in an assignment to a wire, the width of a localparam should be used to
determine the width of the right hand side expression. I.e. the right hand side
of the localparam assignment should effectively be **~4'b0001**.

In my tests I have run this module with:

    vlogcomp issue_018.v
    fuse -o issue_018 issue_018

    ./issue_018
    ISim> run all

Crosscheck: Vivado 2013.4, XST 14.7, Quartus 13.1 and Modelsim 10.1d implement
this correctly.

**History:**  
2014-01-23 [Reported](http://forums.xilinx.com/t5/Simulation-and-Verification/ISIM-handling-width-of-localparam-incorrectly/td-p/406335) bug in Xilinx Support Forum  
2014-01-24 WONTFIX-Notice from Xilinx

