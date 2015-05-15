
XSim implements 0 ** -1 incorrectly
===================================

~CLOSED~ XSim 2015.1

The following module should return **8'bx** for both outputs (see table 5-6 of IEEE Std 1364-2005):

    :::Verilog
    module issue_019(y0, y1);
      output [7:0] y0;
      output [7:0] y1;
      assign y0  = 8'sd0 ** -8'sd1;
      assign y1  = 8'd 0 ** -8'sd1;
      initial #10 $display("%b %b", y0, y1);
    endmodule

But XSim 2013.4 returns **8'b0** instead.

In my tests I have run this module with:

    xvlog issue_019.v
    xelab -R work.issue_019

Crosscheck: Modelsim 10.1d implements this correctly. Isim 14.7 has the same bug.

**History:**  
2014-01-24 [Reported](http://forums.xilinx.com/t5/Simulation-and-Verification/XSim-implements-0-1-incorrectly/td-p/406517) bug in Xilinx Support Forum  
2014-04-16 [Still broken in XSim 2014.1](http://forums.xilinx.com/t5/Synthesis/Bugs-in-Vivado-2014-1/td-p/440750)  
2015-05-15 Fixed in XSim 2015.1  
