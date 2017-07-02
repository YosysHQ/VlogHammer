
Invalid optimization of reduce expression with undef bits
=========================================================

~OPEN~ Quartus 17.0

Consider the following test case:

    :::Verilog
    module issue_042(y);
      output [3:0] y;
      localparam [3:0] p11 = 1'bx;
      assign y = ~&p11;
    endmodule

Quartus 15.0 sets y to constant 4'b0000. The correct value for y
would be 4'b0001.

Crosscheck: Vivado 2015.1, XSim 2015.1, Modelsim 10.3d, Icarus Verilog (git
02ee387), and Verilator (git e5af46d) all agree on the correct behavior.

**History:**  
2015-05-15 Reported via Altera mySupport (SR #11146970)  
2017-07-01 Still broken in Quartus II 17.0  
