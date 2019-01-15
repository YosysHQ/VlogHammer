
Incorrect bit-extension of undef const in ?: operator
=====================================================

~CLOSED~ Vivado 2018.3

Consider the following test case:

    :::Verilog
    module issue_026(a, b, y);
      input [1:0] a;
      input [1:0] b;
      output [3:0] y;
      wire [1:0] y1;
      wire [1:0] y2;
      wire u = 1'bx;
      assign y1 = a ? 1'bx : b;
      assign y2 = a ? u : b;
      assign y = { y1, y2 };
    endmodule

This is expected to set the MSBs of y1 and y2 to 0 for a=2'b11 and
b=2'b11, but the Vivado 2015.1 synthesis output sets **y2=2'b11**.

Crosscheck: XSim 2015.1, Modelsim 10.3d, Icarus Verilog (git 02ee387), and
Verilator (git e5af46d) implement this correctly. Quartus 15.0 gets y2
right but has a bug regarding y1.

**History:**  
2015-05-15 [Reported](http://forums.xilinx.com/t5/Synthesis/Old-and-new-Vivado-Synthesis-Bugs/td-p/602988) bug in Xilinx Support Forum  
2016-06-15 Still broken in Vivado 2016.2  
2017-07-01 Still broken in Vivado 2017.2  
2019-01-15 Fixed in Vivado 2018.3  
