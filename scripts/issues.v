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
  // with b is done in an unsinged context (b is unsigned).
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
