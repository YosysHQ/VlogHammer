
Quartus Verilog bug in handling $signed in an unsigned expression
=================================================================

~OPEN~ Quartus 17.0

The following module should output constant **0**, but quartus 13.1 generates a
module that outputs constant **1** instead.

    :::Verilog
    module issue_002(y);
      wire [1:0] a = 2'b  11;
      wire [2:0] b = 3'b 111;
      output [0:0] y;
      assign y = $signed(a) == b;
    endmodule

Analysis: The argument of **$signed** is self determined. So even though the
comparison is a 3 bit operator, $signed(a) returns the two bit value
**2'bs11**. This is then extended to 3 bits, but because **b** is unsigned this
is not a sign extension but a zero padding. Thus the expression is **3'b011 ==
3'b111**, which is false.

In my tests I have synthesized the module with:

    quartus_map issue_002 --source=issue_002.v --family="Cyclone III"
    quartus_fit issue_002
    quartus_eda issue_002 --formal_verification --tool=conformal

Crosscheck: Vivado 2013.4, XST 14.7, Isim 14.7 and Modelsim 10.1d implement this
correctly.

**History:**  
2014-01-23 Reported via Altera mySupport (SR #11025071)  
2014-03-22 Bugfix for Quartus II v14.1 prospected by Altera Support  
2014-09-28 Verified that bug is still present in Quartus II v14.0  
2015-05-15 Still broken in Quartus II 15.0  
2017-07-01 Still broken in Quartus II 17.0  
