
Verilator thinks ~|a and ~(|a) are the same thing
=================================================

~CLOSED~ Verilator GIT d04eb97

The following module should return **4'b0000** or **4'b0001** but Verilator
GIT fb4928b returns **4'b1111** or **4'b1110** instead.

    :::Verilog
    module issue_034(a, y);
      input [3:0] a;
      output [3:0] y;
      assign y = ~|a;
    endmodule

Note: The **~|** in **~|a** is the nor reduction operator. This is different
from **~(|a)**.

Crosscheck: Vivado 2013.4, XST 14.7, Quartus 13.1, Xsim 2013.4 and Modelsim
10.1d implement this correctly.

Self-contained test case:
[test005.v](http://svn.clifford.at/handicraft/2014/verilatortest/test005.v),
[test005.cc](http://svn.clifford.at/handicraft/2014/verilatortest/test005.cc),
[test005.sh](http://svn.clifford.at/handicraft/2014/verilatortest/test005.sh)

**History:**  
2014-04-09 Reported as [Issue #736](http://www.veripool.org/issues/736-Verilator-Verilator-thinks-a-and-a-are-the-same-thing)  
2014-04-06 Fixed in GIT commit d04eb97  
