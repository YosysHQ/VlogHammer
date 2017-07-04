
Verific hangs on power operations with large exponents
======================================================

~CLOSED~ Verific 463_32_140722

The following module should set y to constant **6'b110011**, but instead it just
hangs Verific 463_32_140306:

    :::Verilog
    module issue_021(a, y);
        input [31:0] a;
        output [5:0] y;
        assign y = 6'd3 ** 123456789;
    endmodule

It seems as if Verific tries to calculate the power by simply performing
123456789 (or rather 123456788) multiplications. But the power operator should
of course be implemented using a proper power-modulus algorithm.

**History:**  
2014-03-22 Reported bug to Verific support  
2014-03-26 Bug added to issue tracker: VIPER Issue #8533  
2014-07-23 Fixed in Verific 463_32_140722  
