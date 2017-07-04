
Verific sign handling bug in {N{...}} Verilog operator
======================================================

~CLOSED~ Verific 463_32_140722

According to the Verilog standard (see sec. 5.1.14 of IEEE Std 1364-2005) the
expressions for **y0** and **y1** in the following example are equivialent and should
yield the same results:

    :::Verilog
    module issue_000(a, y0, y1);
        input signed [1:0] a;
        output [4:0] y0;
        output [4:0] y1;
        // concatenate and replicate operators do not preserve signedness.
        // the MSB of of y0 and y1 must be constant zero.
        assign y0 = {a,a};
        assign y1 = {2{a}};
    endmodule

However, Verific 463_32_140306 handles **{a,a}** as an unsigned and **{2{a}}** as a signed expression (it should be handled as unsigned in both cases).

In other words, Verific connects the MSB of **y0** to GND and the MSB of **y1** to the MSB of **a**, but it should set the MSB of **y1** to zero as well.

**History:**  
2014-03-08 Reported bug to Verific support  
2014-03-18 Bug added to issue tracker: VIPER Issue #8510  
2014-07-23 Fixed in Verific 463_32_140722  

