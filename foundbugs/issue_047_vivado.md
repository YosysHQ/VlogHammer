
Ignored non-trivial initial section
===================================

~OPEN~ Vivado 2015.1

Consider the following test case:

    :::Verilog
    module issue_047(y);
      output reg [80:0] y;
    
      function int_to_bit;
        input [1:0] i;
        begin
          int_to_bit = i[1] ? 1'bx : i[0];
        end
      endfunction
    
      integer i1, i2, i3, i4;
      initial begin
        for (i1 = 0; i1 < 3; i1 = i1+1)
        for (i2 = 0; i2 < 3; i2 = i2+1)
        for (i3 = 0; i3 < 3; i3 = i3+1)
        for (i4 = 0; i4 < 3; i4 = i4+1)
          y[i1 + 3*i2 + 9*i3 + 27*i4] <= { int_to_bit(i1), int_to_bit(i2) } == { int_to_bit(i3), int_to_bit(i4) };
      end
    endmodule

Vivado 2015.1 simply ignores the initial setion and leaves y unconnected.

Crosscheck: Quartus 15.0 implements this correctly. XSim 2015.1, Modelsim
10.3d, Icarus Verilog (git 02ee387), and Verilator (git e5af46d) simulate this
correctly.

**History:**  
2015-05-15 [Reported](http://forums.xilinx.com/t5/Synthesis/Old-and-new-Vivado-Synthesis-Bugs/td-p/602988) bug in Xilinx Support Forum  
