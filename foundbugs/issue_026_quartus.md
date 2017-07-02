
Incorrect bit-extension of undef const in ?: operator
=====================================================

~OPEN~ Quartus 17.0

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
b=2'b11, but the Quartus 15.0 synthesis output sets **y1=2'b11**.

Crosscheck: XSim 2015.1, Modelsim 10.3d, Icarus Verilog (git 02ee387), and
Verilator (git e5af46d) implement this correctly. Vivado 2015.1 gets y1
right but has a bug regarding y2.

**History:**  
2015-05-15 Reported via Altera mySupport (SR #11146970)  
2017-07-01 Still broken in Quartus II 17.0  
