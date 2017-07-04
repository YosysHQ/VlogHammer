
Another strange icarus expression eval bug (large shifts)
=========================================================

~CLOSED~ Icarus GIT b7b77b2

For `b != 0` this should return `y[3:2] == 0`.

    :::Verilog
    module issue_048(a, b, y);
      input [1:0] a;
      input [2:0] b;
      output [3:0] y;
      assign y = {a >> {22{b}}, a << (0 <<< b)};
    endmodule

But iverilog 020e280 returns `y[3:2] == y[1:0]` instead.

**History:**  
2014-05-19 [Reported](https://github.com/steveicarus/iverilog/issues/22) bug on GitHub  
2014-05-20 Fixed in GIT b7b77b2  
