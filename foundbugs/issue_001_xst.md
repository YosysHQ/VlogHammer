
XST handling of constant first argument in Verilog ?: operator
==============================================================

~WONTFIX~ XST 14.7

In the following test case the output should be constant zero:

    :::Verilog
    module issue_001(a, b, y);
        input [2:0] a;
        input [3:0] b;
        output [0:0] y;
        // the ?: must evaluate to the max width of both cases,
        // even if we can be sure that always the smaller case gets selected
        assign y = &( 1 ? a : b );
    endmodule

Sec. 5.1.13 of the Verilog Standard (IEEE Std 1364-2005) states:

> [...] If the lengths of expression2 and expression3 are different, the shorter operand shall be
lengthened to match the longer and zero-filled from the left (the high-order end).

So with the condition beeing constant true, the expression in the parentheses must evaluate to {1'b0, a} and not simply a becasue of the size difference of a and b, thus the &-reduce operator should always see at least this one zero-bit and thus always return 0. But XST does not perform the zero filling and therefore produces an incorrect result.

This is with ISE 14.7 and the following XST settings:

    run -ifn issue_001.prj -ofn issue_001 -p artix7 -top issue_001 -iobuf NO

Crosscheck: Vivado 2013.4, Isim 14.7 and Modelsim 10.1d implement this correctly.
Quartus 13.1 however seems to have [the same bug](issue_001_quartus.html).

**History:**  
2014-01-10 [Reported](http://forums.xilinx.com/t5/Synthesis/Bug-in-XST-handling-of-constant-first-argument-in-Verilog/td-p/401407) bug in Xilinx Support Forum  

