
Ignored width extension for constant ?: condition
=================================================

~OPEN~ Quartus 17.0

Consider the following test case:

    :::Verilog
    module issue_044(a, y);
      input [3:0] a;
      output [3:0] y;
      assign y = &(0 ? 0 : (&a));
    endmodule

Because of the rules for verilog bit width extension, y in this module is
constant zero: When a=4'b1111, then &a=1'b1, which is extended to the size of
'0' (which must be at least 32 bits), yielding &(32'b000...0001) which evaluates
to zero. For all other values of a the example is trivially zero.

But Quartus 15.0 incorrectly converts the expression to &a.

Crosscheck: Vivado 2015.1, XSim 2015.1, Modelsim 10.3d, Icarus Verilog (git
02ee387), and Verilator (git e5af46d) all agree on the correct behavior.

**History:**  
2015-05-15 Reported via Altera mySupport (SR #11146970)  
2017-07-01 Still broken in Quartus II 17.0  
