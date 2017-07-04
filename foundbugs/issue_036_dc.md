
Design Compiler bug regarding shift operations and bit width
============================================================

~WONTFIX~ DC G-2012.06-SP4

The following test case demonstrates that there is a bug in DC G-2012.06-SP4
regarding shift operations and bit width:

    :::Verilog
    module issue_036(a, b, c, d, y1, y2, y3);
      input [3:0] a;
      input [3:0] b;
      input [3:0] c;
      input [3:0] d;
      output [3:0] y1;
      output [3:0] y2;
      output [3:0] y3;
    
      // This should return y=15 for a=15, b=15, c=15, d=15.
      // But Design Compiler G-2012.06-SP4 returns y=7 instead.
      assign y1 = a >>> ((b == c) >>> d);
    
      // This should return 1 but DC G-2012.06-SP4 returns 0 instead.
      assign y2 = (|1 >>> 1) == |0;
    
      // This should return 0 but DC G-2012.06-SP4 returns 1 instead.
      assign y3 = {|1 >>> 1};
    endmodule

A script that does synthesis and pre/post simulation can be found here:  
[http://svn.clifford.at/handicraft/2014/vlogdctests/test001.sh](http://svn.clifford.at/handicraft/2014/vlogdctests/test001.sh)

Crosscheck: Vivado 2014.4, Quartus II 13.1, XST 14.7, Verific 35_463_32_140306,
XSim 2014.4, Modelsim 10.1d, Iacrus GIT 6547fde and Verilator GIT f705f9b
implement this correctly.

**History:**  
2014-05-26 Formulated original bug report  
