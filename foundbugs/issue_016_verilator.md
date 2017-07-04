
Bug in Verilator signed/unsigned handling in power operator
===========================================================

~CLOSED~ Verilator GIT ff19dd9

The following module should return 0 for both outputs:

    :::Verilog
    module issue016(y0, y1);
      output [3:0] y0;
      output [3:0] y1;
      assign y0  = -4'd1 ** -4'sd2;
      assign y1  = -4'd1 ** -4'sd3;
    endmodule

But Verilator 3.856 sets **y0 = 4'b0001** and **y1 = 4'b1111**.

Analysis: The 1st operand of the power operator is (unsigned) **4'b1111**
in both cases. The 2nd operand of the power operator is self determined and its
sign is not influenced by the rest of the expressions (see table 5-22 and sec.
5.5.1 of IEEE Std 1364-2005). According to table 5-6 of IEEE Std 1364-2005
this should return zero.

Crosscheck: Vivado 2013.4, XST 14.7, Isim 14.7 and Modelsim 10.1d implement this
correctly.

**History:**  
2014-04-03 Reported as [Issue #730](http://www.veripool.org/issues/730-Verilator-Bug-in-Verilator-signed-unsigned-handling-in-power-operator)  
2014-04-06 Fixed in GIT commit ff19dd9  
