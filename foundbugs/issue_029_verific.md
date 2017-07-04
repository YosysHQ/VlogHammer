
Verific only using the lowest 32 bits of right shift operand
============================================================

~CLOSED~ Verific 463_32_140722

The following module should output constant **0**.

    :::Verilog
    module issue_029(a, y);
        input [3:0] a;
        output [3:0] y;
        assign y = 4'b1 << 33'h100000000;
    endmodule

However, Verific 463_32_140306 seems to only use the lower 32 bits of the
right operand and thus returns **1** instead.

Crosscheck: Quartus 13.1 and XST 14.7 inherit this bug from Verific. Xsim 
2013.4 has the same problem. Vivado 2013.4 and Modelsim 10.1d implement 
this correctly.

**History:**  
2014-03-22 Reported bug to Verific support  
2014-03-26 Bug added to issue tracker: VIPER Issue #8534  
2014-07-23 Fixed in Verific 463_32_140722  
