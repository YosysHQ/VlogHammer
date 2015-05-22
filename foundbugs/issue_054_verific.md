
Verific sign handling in {N{...}} and {...} again
=================================================

~CLOSED~ Verific 482_32_150519

The following test case is similar to issue_000 (VIPER Issue #8510).
Verific 463_32_140722 passes issue_000 but fails to implement
**y1** and **y5** correctly in the following module:

    :::Verilog
    module issue_054(a, y0, y1, y2, y3, y4, y5, y6, y7);
      input signed [1:0] a;
      output [7:0] y0, y1, y2, y3, y4, y5, y6, y7;
    
      assign y0 = {1'sb1};
      assign y1 = {1{1'sb1}};
      assign y2 = {1'sb1, 1'sb1};
      assign y3 = {2{1'sb1}};
      assign y4 = {a};
      assign y5 = {1{a}};
      assign y6 = {a, a};
      assign y7 = {2{a}};
    endmodule

As in issue_000 the problem is that the replication operator fails to set the
expression to unsigned (I suppose because it is optimized away), leading to
signed instead of unsigned extension to 8 bits.

**History:**  
2014-07-23 Reported bug to Verific support  
2015-05-20 Fixed in Verific 482_32_150519  

