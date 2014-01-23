
Strange output-const-zero bug with Vivado + >>> + signedness
============================================================

~OPEN~ Vivado 2013.4

The following test case is synthesized to a constant zero output by Vivado:
 
    :::Verilog
    module issue_004(a, b, y);
        input a, b;
        output signed [1:0] y;
        // for some reason vivado thinks this is constant 0.
        // this is obviously not true for a=1 and b=0.
        assign y = $signed(a >>> b);
    endmodule

Interestingly the bug goes away when y is not declared signed, even though the
signedness of the left hand side of a verilog assign statement should have no
effect on the statement at all (see Sec. 5.5.3 of IEEE Std 1364-2005).
 
This is with Vivado 2013.4 and the following TCL script:
 
    read_verilog issue_004.v
    synth_design -part xc7k70t -top issue_004
    write_verilog -force issue_004_netlist.v

**History:**  
2014-01-10 [Reported](http://forums.xilinx.com/t5/Synthesis/Strange-output-const-zero-bug-with-Vivado-gt-gt-gt-signedness/td-p/401411) bug in Xilinx Support Forum


