
Quartus handling of constant first argument in Verilog ?: operator
==================================================================

~OPEN~ Quartus 17.0

Consider the following test case:

    :::Verilog
    module issue_001(a, b, y);
        input [2:0] a;
        input [3:0] b;
        output [0:0] y;
        // the ?: must evaluate to the max width of both cases,
        // even if we can be sure that always the smaller case gets selected
        assign y = &( 1 ? a : b );
    endmodule

The output of this module should be constant zero. Here is a short analysis of why this is so:

Sec. 5.1.13 of the Verilog Standard (IEEE Std 1364-2005), which describes the ?: statement, states:

> [...] If the lengths of expression2 and expression3 are different, the
shorter operand shall be lengthened to match the longer and zero-filled from
the left (the high-order end).

So with the condition being constant true, the expression in the parentheses
must evaluate to **{1'b0, a}** and not simply **a** because of the size
difference of **a** and **b**, thus the &-reduce operator should always see at
least this one zero-bit and thus always return 0.

But Quartus 13.1 does not perform the zero filling and therefore produces an
incorrect result, which is equivalent to **assign y = &a;**.

In my tests I have synthesized the module with

    quartus_map issue_001 --source=issue_001.v --family="Cyclone III"
    quartus_fit issue_001
    quartus_eda issue_001 --formal_verification --tool=conformal

Crosscheck: Vivado 2013.4, Isim 14.7 and Modelsim 10.1d implement this
correctly. Interestingly XST 14.7 suffers from [the same bug](issue_001_xst.html).

**History:**  
2014-01-13 Reported via Altera mySupport (SR #11021734)  
2014-01-22 Bugfix for Quartus II v14.1 prospected by Altera Support  
2014-09-28 Verified that bug is still present in Quartus II v14.0  
2015-05-15 Still broken in Quartus II 15.0  
2017-07-01 Still broken in Quartus II 17.0  
