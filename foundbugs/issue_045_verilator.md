
Verilator internal fault related to huge shifts
===============================================

~CLOSED~ Verilator GIT 06744b6

Verilator d7e4bc1 fails with an internal error on the following code:

    :::Verilog
    module issue_045(a, y);
      input signed [15:0] a;
      output [15:0] y;
      assign y = (a >> 16) >>> 32'h7ffffff1;
    endmodule

The error created is:

    %Error: Verilator internal fault, sorry.  Consider trying --debug --gdbbt
    %Error: Command Failed /usr/local/bin/verilator_bin -cc -Wno-fatal -DSIMLIB_NOMEM -DSIMLIB_NOSR -DSIMLIB_NOLUT --top-module test rtl/test.v

**History:**  
2014-05-15 Reported as [Issue #766](http://www.veripool.org/issues/766-Verilator-Verilator-internal-fault-related-to-huge-shifts)  
2014-05-16 Fixed in GIT commit 06744b6  
