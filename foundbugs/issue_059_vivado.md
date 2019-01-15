
Vivado hangs forever on modulo with undefined (X) value
=======================================================

~OPEN~ Vivado 2018.3

Consider the following test case:

    :::Verilog
    module issue_059(a, y);
        input [2:0] a;
        output [3:0] y;
        assign y = a % 1'bx;
    endmodule

Vivado simply hangs forever trying to synthesize this design.

Vivado produces a "CRITICAL WARNING: [Synth 8-5821] Potential divide by zero" message
when modulo (`%`) is replaced with divide (`/`). But when Vivado is run with
`set_msg_config -id {Synth 8-5821} -new_severity {WARNING}` then the case using
division also hangs forever.

**History:**  
2019-01-15 Initial description of bug.  
