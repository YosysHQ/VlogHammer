
Vivado hangs on power operations with large exponents
=====================================================

~OPEN~ Vivado 2018.3

The following module should set y to constant **6'b110011**, but instead it just
hangs Vivado 2018.3:

    :::Verilog
    module issue_021(a, y);
        input [31:0] a;
        output [5:0] y;
        assign y = 6'd3 ** 123456789;
    endmodule

It seems as if Vivado tries to calculate the power by simply performing
123456789 (or rather 123456788) multiplications. But the power operator should
of course be implemented using a proper power-modulus algorithm.

**History:**  
2019-01-15 Initial description of bug.  
