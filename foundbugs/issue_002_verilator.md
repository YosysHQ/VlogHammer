
Verilator bug in handling $signed in an unsigned expression
===========================================================

~CLOSED~ Verilator GIT 14fcfd8

The following module should output **0** for **a = 2'b11** and **b = 3'b111**.
But Verilator 3.856 outputs **1** instead.

    :::Verilog
    module issue_002(a, b, y);
      input [1:0] a;
      input [2:0] b;
      output [0:0] y;
      assign y = $signed(a) == b;
    endmodule

Analysis: The argument of **$signed** is self determined. So even though the
comparison is a 3 bit operator, $signed(a) returns the two bit value
**2'bs11**. This is then extended to 3 bits, but because **b** is unsigned this
is not a sign extension but a zero padding. Thus the expression is **3'b011 ==
3'b111**, which is false.

Crosscheck: Vivado 2013.4, XST 14.7, Isim 14.7 and Modelsim 10.1d implement this
correctly.

**History:**  
2014-04-03 Reported as [Issue #729](http://www.veripool.org/issues/729-Verilator-Verilator-bug-in-handling-signed-in-an-unsigned-expression)  
2014-04-06 Fixed in GIT commit 14fcfd8  
