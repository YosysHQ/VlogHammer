
Strange Verilator behavior with power, signdness and more
=========================================================

~CLOSED~ Verilator GIT fb4928b

The following module should output **0x00000000** for **a=0** and
**0x010000ff** for **a=1**. But Verilator GIT 5c39420 outputs **0xffffffff**
for **a=1** instead.

    :::Verilog
    module test004(a, y);
      input a;
      output [31:0] y;
    
      wire [7:0] y0;
      wire [7:0] y1;
      wire [7:0] y2;
      wire [7:0] y3;
      assign y = {y0,y1,y2,y3};
    
      localparam [7:0] v0 = +8'sd1 ** -8'sd2;
      localparam [7:0] v1 = +8'sd2 ** -8'sd2;
      localparam [7:0] v2 = -8'sd2 ** -8'sd3;
      localparam [7:0] v3 = -8'sd1 ** -8'sd3;
      localparam [7:0] zero = 0; 
    
      assign y0 = a ? v0 : zero;
      assign y1 = a ? v1 : zero;
      assign y2 = a ? v2 : zero;
      assign y3 = a ? v3 : zero;
    endmodule

Interestingly the output value for y3 is correct, but setting y3 to
a constant value (or otherwise removing the calculation for y3) makes the
problem go away. Replacing **a** with **1** in the assign statements
also does make the problem disappear.

Self-contained test case:
[test004.v](http://svn.clifford.at/handicraft/2014/verilatortest/test004.v),
[test004.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test004.cc),
[test004.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test004.sh)

**History:**  
2014-04-08 Reported as [Issue #735](http://www.veripool.org/issues/735-Verilator-Strange-Verilator-behavior-with-power-signdness-and-more)  
2014-04-09 Fixed in GIT commit fb4928b  
