
Icarus does undef propagation of const adds incorrectly
=======================================================

~CLOSED~ Icarus GIT a3450bf

The following module should set both outputs to constant **4'bxxxx**:

    :::Verilog
    module test(a, y1, y2);
      input [1:0] a;
      output [3:0] y1, y2;
      assign y1 = 4'bxx00 + 2'b00;
      assign y2 = 4'bxx00 + a;
    endmodule

But Icarus Verilog (git 5a06602) does only the case involving a variable
correctly. In the constant case it is too smart and outputs **4'bxx00** instead.

**History:**  
2014-02-20 [Reported](https://github.com/steveicarus/iverilog/issues/15) bug on GitHub  
2014-02-25 Fixed in GIT commit [a3450bf](https://github.com/steveicarus/iverilog/commit/a3450bf8560739caea01dbc72dfb6266d144070e)  
