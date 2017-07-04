
XST sign handling bug in {N{...}} Verilog operator
==================================================

~WONTFIX~ XST 14.7

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

However, XST handles **{a,a}** as an unsigned and **{2{a}}** as a signed expression (it should be handled as unsigned in both cases).

In other words, XST connects the MSB of **y0** to GND and the MSB of **y1** to the MSB of **a**, but it should set the MSB of **y1** to zero as well.

This is with ISE 14.7 and the following XST settings:

    run -ifn issue_000.prj -ofn issue_000 -p artix7 -top issue_000 -iobuf NO

Crosscheck: Vivado 2013.4, Quartus 13.1, Isim 14.7 and Modelsim 10.1d implement this correctly.

**History:**  
2014-01-10 [Reported](http://forums.xilinx.com/t5/Synthesis/XST-14-7-sign-handling-bug-in-N-Verilog-operator/td-p/401399) bug in Xilinx Support Forum  

