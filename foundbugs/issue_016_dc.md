
Design Compiler bug in power operator
=====================================

~WONTFIX~ DC G-2012.06-SP4

The following module should set y0=0 and y1=0 (see for example table 5-5 of
IEEE Std 1364-2005). But DC G-2012.06-SP4 sets y0=1 and y1=15.

    :::Verilog
    module issue_016(y0, y1);
      output [3:0] y0;
      output [3:0] y1;
    
      // this should return zero (see table 5-5 of IEEE Std 1364-2005)
      assign y0  = -4'd1 ** -4'sd2;
      assign y1  = -4'd1 ** -4'sd3;
    endmodule

A script that does synthesis and pre/post simulation can be found here:  
[http://svn.clifford.at/handicraft/2014/vlogdctests/test002.sh](http://svn.clifford.at/handicraft/2014/vlogdctests/test002.sh)

Crosscheck: Vivado 2014.4, XST 14.7, Verific 35_463_32_140306,
XSim 2014.4, Modelsim 10.1d, Iacrus GIT 6547fde and Verilator GIT f705f9b
implement this correctly. Quartus II 13.1 has the same bug.

**History:**  
2014-05-26 Formulated original bug report  

