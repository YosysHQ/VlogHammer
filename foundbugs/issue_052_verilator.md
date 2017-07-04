
Strange Verilator "Unsupported" Error
=====================================

~CLOSED~ Verilator GIT e8edbad

Verilator f705f9b prints `%Error: rtl.v:4: Unsupported: 4-state numbers in this context`
for the following input:

    :::Verilog
    module issue_052(y);
      output [3:0] y;
      assign y = ((0/0) ? 1 : 2) % 0;
    endmodule

The strange part is this: The statements `assign y = (0/0) % 0;` and
`assign y = (0/0) ? 1 : 2;` are both accepted by Verilator.

**History:**  
2014-05-24 Reported as [Issue #775](http://www.veripool.org/issues/775-Verilator-Strange-Verilator-Unsupported-Error)  
2014-09-25 Fixed in GIT commit e8edbad  
