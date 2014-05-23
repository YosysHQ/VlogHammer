
Another Verilator Internal Error for shift by undef value
=========================================================

~OPEN~ Verilator GIT 06744b6

Verilator 06744b6 creates the following error:  
`%Error: Internal Error: ../V3Number.cpp:521: toUInt with 4-state 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

    :::Verilog
    module issue_049(a, y);
      input [3:0] a;
      output [3:0] y;
      assign y = a << 1 <<< 0/0;
    endmodule

**History:**  
2014-05-23 Reported as [Issue #772](http://www.veripool.org/issues/772-Verilator-Another-Verilator-Internal-Error-for-shift-by-undef-value)
