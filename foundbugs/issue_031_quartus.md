
Invalid optimization of or-reduce with undef bits
=================================================

~OPEN~ Quartus 17.0

Consider the following test case:

    :::Verilog
    module issue_031(a, y);
      input [2:0] a;
      output [2:0] y;
      assign y = { &{a,1'bx}, |{a,1'bx}, ^{a,1'bx} };
    endmodule

Quartus 15.0 sets y to constant 3'b000. But for y[1] only '1' is a valid
constant value.

Crosscheck: Vivado 2015.1, XSim 2015.1, Modelsim 10.3d, Icarus Verilog (git
02ee387), and Verilator (git e5af46d) all agree on the correct behavior.

**History:**  
2015-05-15 Reported via Altera mySupport (SR #11146970)  
2017-07-01 Still broken in Quartus II 17.0  
