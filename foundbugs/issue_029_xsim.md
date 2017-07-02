
Handling of large RHS in shift operator
=======================================

~CLOSED~ XSim 2017.2

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

The wire y1 should be constant zero. But XSim 2015.0 sets y1=1.

For a!=0 the wire y2 should be zero. But XSim 2015.0 sets y2=1.

Crosscheck: Vivado 2015.1, Modelsim 10.3d, Icarus Verilog (git 02ee387), and
Verilator (git e5af46d) implement this correctly.

**History:**  
2015-05-15 [Reported](http://forums.xilinx.com/t5/Simulation-and-Verification/Old-and-new-XSim-bug-reports/td-p/602984) bug in Xilinx Support Forum  
2017-07-01 Fixed in XSim 2017.2  
