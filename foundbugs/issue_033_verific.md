
Verific incorrectly const folds a == 1'bx
==========================================

~CLOSED~ Verific 482_32_150519

Consider the following module:

    :::Verilog
    module issue_033(a, y);
        input [1:0] a;
        output y;
        assign y = a == 1'bx;
    endmodule

For **a[1] == 1** this module should output zero. (The **1'bx** is zero
extended to **2'b0x**. Unlike the relational operators, the **==** and
**!=** operators do not automatically output **1'bx** if any bit in the
arguments is **1'bx**. Instead it must only output **1'bx** if the
result is ambiguous. See also 5.1.8 in IEE Std 1364-2005.)

However, Verific 463_32_140306 optimizes all logic out of this module and
sets the output to constant **1'bx**.

**History:**  
2014-03-22 Reported bug to Verific support  
2014-03-26 Bug added to issue tracker: VIPER Issue #8535  
2014-07-23 Still broken in Verific 463_32_140722  
2015-05-20 Fixed in Verific 482_32_150519  

