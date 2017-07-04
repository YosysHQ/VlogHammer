
Verilator bug in signdness of {..}
==================================

~CLOSED~ Verilator GIT 4a58e85

Verilator a985a1f returns 11001 instead of 01001, i.e. verilator
performs sign extension even though the result of `{ .. }` is unsigned.

    :::Verilog
    module issue_038(y);
    	output [4:0] y;
    	assign y = { -4'sd7 };
    endmodule

Self-contained test case:
[test010.v](http://svn.clifford.at/handicraft/2014/verilatortest/test010.v),
[test010.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test010.cc),
[test010.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test010.sh)

**History:**  
2014-05-03 Reported as [Issue #759](http://www.veripool.org/issues/759-Verilator-Verilator-bug-in-signdness-of-)  
2014-05-03 Fixed in GIT commit 4a58e85  
