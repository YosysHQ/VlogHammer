
Quartus hangs on power operations with large exponents
======================================================

~OPEN~ Quartus 17.0

The following module should set **y** to constant **6'b110011**, but instead it
just hangs quartus 13.1:

    :::Verilog
    module issue_021(y);
      output [5:0] y;
      assign y = 6'd3 ** 123456789;
    endmodule

Quartus seems to try to evaluate this expression by performing 123456789
multiplications instead of using a proper power-modulus algorithm.

In my tests I have synthesized the module with

    quartus_map issue_021 --source=issue_021.v --family="Cyclone III"

Crosscheck: Modelsim 10.1d can simulate this module in an instant and Vivado
2013.4 can synthesize it correctly.

**History:**  
2014-01-25 Reported via Altera mySupport (SR #11025546)  
2014-01-27 Bugfix for Quartus II v14.1 prospected by Altera Support  
2014-09-28 Verified that bug is still present in Quartus II v14.0  
2015-05-15 Still broken in Quartus II 15.0  
2017-07-01 Still broken in Quartus II 17.0  
