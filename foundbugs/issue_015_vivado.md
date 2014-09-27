
Vivado bug in undef handling for relational operators
=====================================================

~CLOSED~ Vivado 2014.2

Consider the following test case with Vivado 2013.4:

    :::Verilog
    module issue_015(a, y0, y1, y2, y3, y4, y5);
      input [3:0] a;
      output [3:0] y0, y1, y2, y3, y4, y5;
    
      assign y0 = a >  4'bx;
      assign y1 = a >= 4'bx;
      assign y2 = a <  4'bx;
      assign y3 = a <= 4'bx;
      assign y4 = a == 4'bx;
      assign y5 = a != 4'bx;
    endmodule

The resulting values for **y0**, .., **y5** should be **4'b000x**, independent
of the value of **a**. (see Sec. 5.1.7 of  IEEE Std. 1364-2005 or compare with
simulation results). So correct synthesis outputs would be **4'b0000** or
**4'b0001**. The three MSB must always be zero.

But Vivado 2013.4 sets all outputs to the value **4'b0010** instead.

I have used the following TCL script for synthesis:

    read_verilog issue_015.v synth_design -part xc7k70t -top issue_015
    write_verilog -force issue_015_netlist.v

Crosscheck: XST 14.7, Quartus 13.1, Isim 14.7 and Modelsim 10.1d implement this
correctly.

**History:**  
2014-01-16 [Reported](http://forums.xilinx.com/t5/Synthesis/Vivado-bug-in-undef-handling-for-relational-operators/td-p/403469) bug in Xilinx Support Forum  
2014-04-16 [Still broken in Vivado 2014.1](http://forums.xilinx.com/t5/Synthesis/Bugs-in-Vivado-2014-1/td-p/440750)  
2014-09-27 Fixed in Vivado 2014.2  
