
Verilator bug in extending $signed
==================================

~CLOSED~ Verilator GIT 5c39420

The following module should output **4'b1111** but Verilator GIT 14fcfd8
outputs **4'b0001** instead.

    :::Verilog
    module issue_005(y);
      wire [3:0] a;
      output [3:0] y;
      assign a = 4'b0010;
      assign y = $signed(|a);
    endmodule

**History:**  
2014-04-06 Reported as [Issue #733](http://www.veripool.org/issues/733-Verilator-Verilator-bug-in-extending-signed)  
2014-04-08 Fixed in GIT commit 5c39420  
