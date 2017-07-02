
Quartus handling of partly out-of-bounds parts select
=====================================================

~OPEN~ Quartus 17.0

Consider the following test case:

    :::Verilog
    module issue_057(a, y);
      input [2:0] a;
      output [3:0] y;
      localparam [5:15] p = 51681708;
      assign y = p[15 + a -: 5];
    endmodule

This is expected to set **y[3]=1** for **a=1**, but the quartus 14.0 synthesis output 
sets **y[3]=0**.

**Test bench:**

    :::Verilog
    `timescale 1ns / 1ps
    module issue_057_tb;
      reg [2:0] a;
      wire [3:0] y;
    
      issue_057 uut (a, y);
    
      initial begin
        a = 1; #1;
        $display("%b %b", a, y);
      end
    endmodule

**Test script:**

    :::Shell
    /opt/altera/14.0/quartus/bin/quartus_map issue_057 --source=issue_057.v --family='Cyclone V'
    /opt/altera/14.0/quartus/bin/quartus_fit issue_057 --part=5CGXFC7D6F27C6
    /opt/altera/14.0/quartus/bin/quartus_eda issue_057 --simulation --tool=modelsim --format=verilog
    
    /opt/altera/14.0/modelsim_ase/bin/vlib gold
    /opt/altera/14.0/modelsim_ase/bin/vlog -work gold issue_057.v
    /opt/altera/14.0/modelsim_ase/bin/vlog -work gold issue_057_tb.v
    
    /opt/altera/14.0/modelsim_ase/bin/vlib gate
    /opt/altera/14.0/modelsim_ase/bin/vlog -work gate simulation/modelsim/issue_057.vo
    /opt/altera/14.0/modelsim_ase/bin/vlog -work gate /opt/altera/14.0/quartus/eda/sim_lib/cyclonev_atoms.v
    /opt/altera/14.0/modelsim_ase/bin/vlog -work gate issue_057_tb.v
    
    /opt/altera/14.0/modelsim_ase/bin/vsim -c -do 'run -all; exit' gold.issue_057_tb
    /opt/altera/14.0/modelsim_ase/bin/vsim -c -do 'run -all; exit' gate.issue_057_tb

Crosscheck: Verific 35_463_32_140722, Modelsim 10.1e, XSim 2014.2 and Icarus Verilog
(git 1572dcd) implement this correctly. Vivado 2014.2 suffers from the same bug.

**History:**  
2014-09-27 Reported via Altera mySupport (SR #11090526)  
2015-05-15 Still broken in Quartus II 15.0  
2017-07-01 Still broken in Quartus II 17.0  
