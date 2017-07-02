
Handling of large constant RHS in shift operator
================================================

~OPEN~ Quartus 17.0

Consider the following test case:

    :::Verilog
    module issue_029(a, y);
      input [3:0] a;
      output [7:0] y;
      wire [3:0] y1;
      wire [3:0] y2;

      assign y1 = 4'b1 << 33'h100000000;
      assign y2 = 1 >> {a, 64'b0};
      assign y = { y1, y2 };
    endmodule

The wire y1 should be constant zero. But Quartus 15.0 synthesis output sets y1=1.

This seems only to be a problem with constant shifts. The wire y2 is handled
correctly.

Crosscheck: Vivado 2015.1, Modelsim 10.3d, Icarus Verilog (git 02ee387), and
Verilator (git e5af46d) implement this correctly.

**History:**  
2015-05-15 Reported via Altera mySupport (SR #11146970)  
2017-07-01 Still broken in Quartus II 17.0  
