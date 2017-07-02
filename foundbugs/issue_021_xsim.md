
XSim hangs on power operations with large exponents
===================================================

~CLOSED~ XSim 2017.2

The following module should return **6'b110011**, but instead it just hangs xsim 2013.4:

    :::Verilog
    module issue_021(y);
      output [5:0] y;
      assign y = 6'd3 ** 123456789;
      initial #10 $display("%b", y);
    endmodule

XSim 2013.4 seems to try to evaluate this expression by performing 123456789
multiplications instead of using a proper power-modulus algorithm.

In my tests I have run this module with:

    xvlog issue_021.v
    xelab -R work.issue_021

Crosscheck: Modelsim 10.1d can simulate this module in an instant and Vivado
2013.4 can synthesize it correctly. Isim 14.7 and XST 14.7 seem to suffer from
a similar problem.

**History:**  
2014-01-25 [Reported](http://forums.xilinx.com/t5/Simulation-and-Verification/XSim-hangs-on-power-operations-with-large-exponents/td-p/406887) bug in Xilinx Support Forum  
2014-04-16 [Still broken in XSim 2014.1](http://forums.xilinx.com/t5/Synthesis/Bugs-in-Vivado-2014-1/td-p/440750)  
2015-05-15 [Still broken in XSim 2015.1](http://forums.xilinx.com/t5/Simulation-and-Verification/Old-and-new-XSim-bug-reports/td-p/602984)  
2017-07-01 Fixed in XSim 2017.2  
