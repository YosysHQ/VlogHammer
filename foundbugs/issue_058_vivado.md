
Strange Vivado bug involving seemingly unrelated expressions
============================================================

~OPEN~ Vivado 2018.3

Consider the following test case:

    :::Verilog
    module issue_058(a, y); 
        input [1:0] a;
        output [3:0] y;
    
        wire [1:0] y0;
        wire [1:0] y1;
        assign y = {y0,y1};
    
        localparam [1:0] p1 = 1;
        localparam [1:0] pX = 1 % 0;
    
        assign y0 = a ? p1 : p1;
        assign y1 = a ^ (a != pX);
    endmodule

This is expected to set **y[3]=0** and **y[2]=1**, but the vivado 2018.3 synthesis output 
sets **y[3]=1** and **y[2]=Z**.

**History:**  
2019-01-15 Initial description of bug.  
