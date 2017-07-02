
Quartus Verilog bug in signdness handling of 2nd shift operand
==============================================================

~OPEN~ Quartus 17.0

The following module should output **5'b11000**, but quartus 13.1 generates a 
module that outputs **5'b00000** instead.

    module issue_003(y);
      output [4:0] y;
      assign y = 4'b1111 << -2'sd1;
    endmodule

Analysis: The 2nd argument of the shift operators (such as **<<**) are
self-determined and are always interpreted as unsigned (see sec. 5.1.12 and
table 5-22 of IEEE Std 1364-2005). So the shift operator in the example
above should implement a three bit left shift.

In my tests I have synthesized the module with

    quartus_map issue_003 --source=issue_003.v --family="Cyclone III"
    quartus_fit issue_003
    quartus_eda issue_003 --formal_verification --tool=conformal

Crosscheck: Vivado 2013.4, XST 14.7, Isim 14.7 and Modelsim 10.1d implement this
correctly.

**History:**  
2014-01-23 Reported via Altera mySupport (SR #11025074)  
2014-01-27 Answer from Altera: Synplify is behaving the same as Quartus II. Altera will investigate.  
2014-02-06 Bugfix for Quartus II v14.1 prospected by Altera Support  
2014-09-28 Verified that bug is still present in Quartus II v14.0  
2015-05-15 Still broken in Quartus II 15.0  
2017-07-01 Still broken in Quartus II 17.0  
