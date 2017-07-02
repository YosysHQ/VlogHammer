
Bug in Quartus signed/unsigned handling in power operator
=========================================================

~OPEN~ Quartus 17.0

The following module should return 0 for both outputs:

    :::Verilog
    module issue016(y0, y1);
      output [3:0] y0;
      output [3:0] y1;
      assign y0  = -4'd1 ** -4'sd2;
      assign y1  = -4'd1 ** -4'sd3;
    endmodule

But quartus 13.1 sets **y0 = 4'b0001** and **y1 = 4'b1111**.

Analysis: The 1st operand of the power operator is (unsigned) **4'b1111**
in both cases. The 2nd operand of the power operator is self determined and its
sign is not influenced by the rest of the expressions (see table 5-22 and sec.
5.5.1 of IEEE Std 1364-2005). According to table 5-6 of IEEE Std 1364-2005
this should return zero.

In my tests I have synthesized the module with:

    quartus_map issue_016 --source=issue_016.v --family="Cyclone III"
    quartus_fit issue_016
    quartus_eda issue_016 --formal_verification --tool=conformal

Crosscheck: Vivado 2013.4, XST 14.7, Isim 14.7 and Modelsim 10.1d implement this
correctly.

**History:**  
2014-01-23 Reported via Altera mySupport (SR #11025077)  
2014-01-27 Bugfix for Quartus II v14.1 prospected by Altera Support  
2014-09-28 Verified that bug is still present in Quartus II v14.0  
2015-05-15 Still broken in Quartus II 15.0  
2017-07-01 Still broken in Quartus II 17.0  
