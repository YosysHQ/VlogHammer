
Verilator Internal Error for shift by undef value
=================================================

~CLOSED~ Verilator GIT 621c515

Verilator 4a58e85 creates the following error:  
`%Error: Internal Error: ../V3Number.cpp:521: toUInt with 4-state 4'bxxxx`

    :::Verilog
    module issue_039(a, y);
      input [3:0] a;
      output [3:0] y;
      assign y = a >>> 4'bx;
    endmodule

**History:**  
2014-05-04 Reported as [Issue #760](http://www.veripool.org/issues/760-Verilator-Verilator-Internal-Error-for-shift-by-undef-value)  
2014-05-04 Fixed in GIT commit 621c515  
