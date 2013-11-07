module issue_000(a, y);
  input signed [1:0] a;
  wire [4:0] y0;
  wire [4:0] y1;
  output [9:0] y;
  assign y = {y0,y1};
  // concatenate and replicate operators do not preserve signedness.
  // the MSB of of y0 and y1 must be constant zero.
  assign y0 = {a,a};
  assign y1 = {2{a}};
endmodule
module issue_001(a, b, y);
  input [2:0] a;
  input [3:0] b;
  output [0:0] y;
  // the ?: must evaluate to the max width of both cases,
  // even if we can be sure that always the smaller case gets selected
  assign y = &( 1 ? a : b );
endmodule
module issue_002(a, b, y);
  input [1:0] a;
  input [2:0] b;
  output [0:0] y;
  // the width of $signed(a) is self-determined. so it must return a 2-bit
  // value that is then zero-extended to three bits because the comparison
  // with b is done in an unsigned context (b is unsigned).
  assign y = $signed(a) == b;
endmodule
module issue_003(a, y);
  input signed [3:0] a;
  output [4:0] y;
  // the right hand side of a shift operation must always be treated as an unsigned number
  assign y = a << -2'sd1;
endmodule
module issue_004(a, b, y);
  input [0:0] a;
  input [0:0] b;
  output signed [3:0] y;
  // for some reason vivado thinks this is constant 0.
  // this is obviously not true for a=1 and b=0.
  assign y = $signed(a >>> b);
endmodule
module issue_005(a, y);
  input signed [2:0] a;
  wire [2:0] y0;
  wire [2:0] y1;
  wire [2:0] y2;
  wire [2:0] y3;
  wire [2:0] y4;
  wire [2:0] y5;
  wire [2:0] y6;
  wire [2:0] y7;
  output [23:0] y;
  assign y = {y0,y1,y2,y3,y4,y5,y6,y7};
  // a couple of test cases for width-extending when $signed() and $unsigned() is used. 
  // the tricky part is to know when the result is 3'bxxx and when it is 3'b00x for a=0.
  assign y0 = $signed(|a);
  assign y1 = $unsigned(|a);
  assign y2 = $signed(|(a/a));
  assign y3 = $unsigned(|(a/a));
  assign y4 = $signed((|a)/(|a));
  assign y5 = $unsigned((|a)/(|a));
  assign y6 = |(a/a);
  assign y7 = (|a)/(|a);
endmodule
module issue_006(a, y);
  input signed [1:0] a;
  wire [0:0] y0;
  wire [0:0] y1;
  output [1:0] y;
  assign y ={y0,y1};
  // the 1'bx must be extended to 2'b0x and not 2'bxx
  assign y0 = a != 1'bx;
  assign y1 = a == 1'bx;
endmodule
module issue_007(a, y);
  input [3:0] a;
  wire [3:0] y0;
  wire [3:0] y1;
  wire [3:0] y2;
  wire [3:0] y3;
  output [15:0] y;
  assign y = {y0,y1,y2,y3};
  // constant evaluation of width-extension with undefs
  localparam [1:0] p0 = |(1/0);
  localparam [1:0] p1 = (|1)/(|0);
  assign y0 = p0;         // 4'b000x
  assign y1 = p1;         // 4'b00xx
  assign y2 = |(1/0);     // 4'b000x
  assign y3 = (|1)/(|0);  // 4'bxxxx
endmodule
