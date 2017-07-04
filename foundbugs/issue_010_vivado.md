
Vivado creates netlist with inputs shorted together
===================================================

~CLOSED~ Vivado 2015.1

Vivado 2013.4 creates a netlist containing shorted together inputs for the following design:

    :::Verilog
    (* use_dsp48="no" *)
    module issue_010(a, b, y);
      input [5:0] a;
      input [3:0] b;
    
      // I have no clue why but Vivado 2013.4 generates a netlist containing:
      //
      //   assign \<const0>  = a[3];
      //   assign \<const0>  = a[2];
      //   assign \<const0>  = a[1];
      //   assign \<const0>  = b[3];
      //   assign \<const0>  = b[2];
      //   assign \<const0>  = b[1];
      //   assign \<const0>  = b[0];
      //
      //   IBUF IBUF
      //         (.I(\<const0> ),
      //          .O(xlnx_opt_));
    
      wire [80:0] y0;
      wire [4:0] y1;
      wire [3:0] y2;
    
      output [89:0] y;
      assign y = {y0,y1,y2};
    
      assign y0  = 0;
      assign y1  = {4{{3{b}}}};
      assign y2  = 4'b1000 * a;
    endmodule

This netlist was generated using the following TCL script:

    read_verilog issue_010.v
    synth_design -part xc7k70t -top issue_010
    write_verilog -force netlist.v

**History:**  
2013-12-29 [Reported](http://forums.xilinx.com/t5/Synthesis/Vivado-creates-netlist-with-inputs-shorted-together/td-p/397161) bug in Xilinx Support Forum  
2014-04-16 [Still broken in Vivado 2014.1](http://forums.xilinx.com/t5/Synthesis/Bugs-in-Vivado-2014-1/td-p/440750)  
2014-09-27 Still broken in Vivado 2014.2  
2015-05-15 Fixed in Vivado 2015.1  
