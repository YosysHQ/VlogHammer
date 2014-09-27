
Vivado GDpGen::implementDivMod(DFNode*, bool): Assertion `TBD' failed.
======================================================================

~CLOSED~ Vivado 2014.2

When I try to synthesize the following module with Vivado 2013.4

    :::Verilog
    module issue_014(a, b, y);
      input [1:0] a;
      input [2:0] b;
      output [3:0] y;
      assign y = $signed(a / b);
    endmodule

I get the following error message:

    vivado: /proj/buildscratch/builds/2013.4/continuous/20131209165331/src/ext/oasys/src/syn/gen/gencore/dp/GDpGenDivMod.cc:324:
    		void GDpGen::implementDivMod(DFNode*, bool): Assertion `TBD' failed.
    Abnormal program termination (6)

This is the TCL script I was using to build the module:

    read_verilog issue_014.v
    synth_design -part xc7k70t -top issue_014
    write_verilog -force issue_014_netlist.v

**History:**  
2014-01-12 [Reported](http://forums.xilinx.com/t5/Synthesis/Vivado-GDpGen-implementDivMod-DFNode-bool-Assertion-TBD-failed/td-p/401721) bug in Xilinx Support Forum  
2014-01-15 Xilinx prospected bugfix in future release  
2014-04-16 [Still broken in Vivado 2014.1](http://forums.xilinx.com/t5/Synthesis/Bugs-in-Vivado-2014-1/td-p/440750)  
2014-09-27 Fixed in Vivado 2014.2  
