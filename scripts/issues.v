module issue_000(a, y);
  // http://forums.xilinx.com/t5/Synthesis/XST-14-7-sign-handling-bug-in-N-Verilog-operator/td-p/401399
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
  // http://forums.xilinx.com/t5/Synthesis/Bug-in-XST-handling-of-constant-first-argument-in-Verilog/td-p/401407
  // Altera Service Request # 11021734
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
  // http://forums.xilinx.com/t5/Synthesis/Strange-output-const-zero-bug-with-Vivado-gt-gt-gt-signedness/td-p/401411
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
  input [4:0] a;
  output [4:0] y;
  // icarus verilog has a bug (git 336b299) that prevents it from
  // evaluating ^~ in parameters. This is just a quick test of all
  // verilog expressions in localparams to catch such bugs.
  localparam [4:0] pb00 = 5'd00 +   5'd3;
  localparam [4:0] pb01 = 5'd01 -   5'd3;
  localparam [4:0] pb02 = 5'd02 *   5'd3;
  localparam [4:0] pb03 = 5'd03 /   5'd3;
  localparam [4:0] pb04 = 5'd04 %   5'd3;
  localparam [4:0] pb05 = 5'd05 **  5'd3;
  localparam [4:0] pb06 = 5'd06 >   5'd3;
  localparam [4:0] pb07 = 5'd07 >=  5'd3;
  localparam [4:0] pb08 = 5'd08 <   5'd3;
  localparam [4:0] pb09 = 5'd09 <=  5'd3;
  localparam [4:0] pb10 = 5'd10 &&  5'd3;
  localparam [4:0] pb11 = 5'd11 ||  5'd3;
  localparam [4:0] pb12 = 5'd12 ==  5'd3;
  localparam [4:0] pb13 = 5'd13 !=  5'd3;
  localparam [4:0] pb14 = 5'd14 === 5'd3;
  localparam [4:0] pb15 = 5'd15 !== 5'd3;
  localparam [4:0] pb16 = 5'd16 &   5'd3;
  localparam [4:0] pb17 = 5'd17 |   5'd3;
  localparam [4:0] pb18 = 5'd18 ^   5'd3;
  localparam [4:0] pb19 = 5'd19 ^~  5'd3;
  localparam [4:0] pb20 = 5'd20 <<  5'd3;
  localparam [4:0] pb21 = 5'd21 >>  5'd3;
  localparam [4:0] pb22 = 5'd22 <<< 5'd3;
  localparam [4:0] pb23 = 5'd23 >>> 5'd3;
  localparam [4:0] pu00 = +  5'd00;
  localparam [4:0] pu01 = -  5'd01;
  localparam [4:0] pu02 = !  5'd02;
  localparam [4:0] pu03 = ~  5'd03;
  localparam [4:0] pu04 = &  5'd04;
  localparam [4:0] pu05 = ~& 5'd05;
  localparam [4:0] pu06 = |  5'd06;
  localparam [4:0] pu07 = ~| 5'd07;
  localparam [4:0] pu08 = ^  5'd08;
  localparam [4:0] pu09 = ~^ 5'd09;
  localparam [4:0] pter = 1 ? 2 : 3;
  assign y = pb00 ^ pb01 ^ pb02 ^ pb03 ^ pb04 ^ pb05 ^ pb06 ^ pb07 ^ pb08 ^
             pb09 ^ pb10 ^ pb11 ^ pb12 ^ pb13 ^ pb14 ^ pb15 ^ pb16 ^ pb17 ^
             pb18 ^ pb19 ^ pb20 ^ pb21 ^ pb22 ^ pb23 ^ pu00 ^ pu01 ^ pu02 ^
             pu03 ^ pu04 ^ pu05 ^ pu06 ^ pu07 ^ pu08 ^ pu09 ^ pter ^ a;
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
module issue_008(a, y);
  input [1:0] a;
  output [127:0] y;

  wire [7:0] y0;
  wire [7:0] y1;
  wire [7:0] y2;
  wire [7:0] y3;
  wire [7:0] y4;
  wire [7:0] y5;
  wire [7:0] y6;
  wire [7:0] y7;
  wire [7:0] y8;
  wire [7:0] y9;
  wire [7:0] y10;
  wire [7:0] y11;
  wire [7:0] y12;
  wire [7:0] y13;
  wire [7:0] y14;
  wire [7:0] y15;
  assign y = {y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15};

  // constant evaluation of power operator (signed ** signed)
  localparam [7:0] ss0  = +8'sd0 ** -8'sd1;
  localparam [7:0] ss1  = +8'sd0 ** +8'sd1;
  localparam [7:0] ss2  = -8'sd2 ** -8'sd2;
  localparam [7:0] ss3  = -8'sd1 ** -8'sd2;
  localparam [7:0] ss4  = +8'sd1 ** -8'sd2;
  localparam [7:0] ss5  = +8'sd2 ** -8'sd2;
  localparam [7:0] ss6  = -8'sd2 ** -8'sd3;
  localparam [7:0] ss7  = -8'sd1 ** -8'sd3;
  localparam [7:0] ss8  = +8'sd1 ** -8'sd3;
  localparam [7:0] ss9  = +8'sd2 ** -8'sd3;
  localparam [7:0] ss10 = +8'sd3 ** +8'sd2;
  localparam [7:0] ss11 = -8'sd1 ** +8'sd1;
  localparam [7:0] ss12 = -8'sd1 ** +8'sd3;
  localparam [7:0] ss13 = -8'sd2 ** +8'sd1;
  localparam [7:0] ss14 = -8'sd2 ** +8'sd3;
  localparam [7:0] ss15 = -8'sd3 ** +8'sd3;

  // constant evaluation of power operator (signed ** unsigned)
  localparam [7:0] su0  = +8'sd0 ** -8'd1;
  localparam [7:0] su1  = +8'sd0 ** +8'd1;
  localparam [7:0] su2  = -8'sd2 ** -8'd2;
  localparam [7:0] su3  = -8'sd1 ** -8'd2;
  localparam [7:0] su4  = +8'sd1 ** -8'd2;
  localparam [7:0] su5  = +8'sd2 ** -8'd2;
  localparam [7:0] su6  = -8'sd2 ** -8'd3;
  localparam [7:0] su7  = -8'sd1 ** -8'd3;
  localparam [7:0] su8  = +8'sd1 ** -8'd3;
  localparam [7:0] su9  = +8'sd2 ** -8'd3;
  localparam [7:0] su10 = +8'sd3 ** +8'd2;
  localparam [7:0] su11 = -8'sd1 ** +8'd1;
  localparam [7:0] su12 = -8'sd1 ** +8'd3;
  localparam [7:0] su13 = -8'sd2 ** +8'd1;
  localparam [7:0] su14 = -8'sd2 ** +8'd3;
  localparam [7:0] su15 = -8'sd3 ** +8'd3;

  // constant evaluation of power operator (unsigned ** signed)
  localparam [7:0] us0  = +8'd0 ** -8'sd1;
  localparam [7:0] us1  = +8'd0 ** +8'sd1;
  localparam [7:0] us2  = -8'd2 ** -8'sd2;
  localparam [7:0] us3  = -8'd1 ** -8'sd2;
  localparam [7:0] us4  = +8'd1 ** -8'sd2;
  localparam [7:0] us5  = +8'd2 ** -8'sd2;
  localparam [7:0] us6  = -8'd2 ** -8'sd3;
  localparam [7:0] us7  = -8'd1 ** -8'sd3;
  localparam [7:0] us8  = +8'd1 ** -8'sd3;
  localparam [7:0] us9  = +8'd2 ** -8'sd3;
  localparam [7:0] us10 = +8'd3 ** +8'sd2;
  localparam [7:0] us11 = -8'd1 ** +8'sd1;
  localparam [7:0] us12 = -8'd1 ** +8'sd3;
  localparam [7:0] us13 = -8'd2 ** +8'sd1;
  localparam [7:0] us14 = -8'd2 ** +8'sd3;
  localparam [7:0] us15 = -8'd3 ** +8'sd3;

  // constant evaluation of power operator (unsigned ** unsigned)
  localparam [7:0] uu0  = +8'd0 ** -8'd1;
  localparam [7:0] uu1  = +8'd0 ** +8'd1;
  localparam [7:0] uu2  = -8'd2 ** -8'd2;
  localparam [7:0] uu3  = -8'd1 ** -8'd2;
  localparam [7:0] uu4  = +8'd1 ** -8'd2;
  localparam [7:0] uu5  = +8'd2 ** -8'd2;
  localparam [7:0] uu6  = -8'd2 ** -8'd3;
  localparam [7:0] uu7  = -8'd1 ** -8'd3;
  localparam [7:0] uu8  = +8'd1 ** -8'd3;
  localparam [7:0] uu9  = +8'd2 ** -8'd3;
  localparam [7:0] uu10 = +8'd3 ** +8'd2;
  localparam [7:0] uu11 = -8'd1 ** +8'd1;
  localparam [7:0] uu12 = -8'd1 ** +8'd3;
  localparam [7:0] uu13 = -8'd2 ** +8'd1;
  localparam [7:0] uu14 = -8'd2 ** +8'd3;
  localparam [7:0] uu15 = -8'd3 ** +8'd3;

  assign y0  = a == 0 ? ss0  : a == 1 ? su0  : a == 2 ? us0  : uu0;
  assign y1  = a == 0 ? ss1  : a == 1 ? su1  : a == 2 ? us1  : uu1;
  assign y2  = a == 0 ? ss2  : a == 1 ? su2  : a == 2 ? us2  : uu2;
  assign y3  = a == 0 ? ss3  : a == 1 ? su3  : a == 2 ? us3  : uu3;
  assign y4  = a == 0 ? ss4  : a == 1 ? su4  : a == 2 ? us4  : uu4;
  assign y5  = a == 0 ? ss5  : a == 1 ? su5  : a == 2 ? us5  : uu5;
  assign y6  = a == 0 ? ss6  : a == 1 ? su6  : a == 2 ? us6  : uu6;
  assign y7  = a == 0 ? ss7  : a == 1 ? su7  : a == 2 ? us7  : uu7;
  assign y8  = a == 0 ? ss8  : a == 1 ? su8  : a == 2 ? us8  : uu8;
  assign y9  = a == 0 ? ss9  : a == 1 ? su9  : a == 2 ? us9  : uu9;
  assign y10 = a == 0 ? ss10 : a == 1 ? su10 : a == 2 ? us10 : uu10;
  assign y11 = a == 0 ? ss11 : a == 1 ? su11 : a == 2 ? us11 : uu11;
  assign y12 = a == 0 ? ss12 : a == 1 ? su12 : a == 2 ? us12 : uu12;
  assign y13 = a == 0 ? ss13 : a == 1 ? su13 : a == 2 ? us13 : uu13;
  assign y14 = a == 0 ? ss14 : a == 1 ? su14 : a == 2 ? us14 : uu14;
  assign y15 = a == 0 ? ss15 : a == 1 ? su15 : a == 2 ? us15 : uu15;
endmodule
module issue_009(a, y);
  input [2:0] a;
  output [75:0] y;

  wire [3:0] y0;
  wire [3:0] y1;
  wire [3:0] y2;
  wire [3:0] y3;
  wire [3:0] y4;
  wire [3:0] y5;
  wire [3:0] y6;
  wire [3:0] y7;
  wire [3:0] y8;
  wire [3:0] y9;
  wire [3:0] y10;
  wire [3:0] y11;
  wire [3:0] y12;
  wire [3:0] y13;
  wire [3:0] y14;
  wire [3:0] y15;
  wire [3:0] y16;
  wire [3:0] y17;
  wire [3:0] y18;

  assign y = {y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17,y18};

  // various tests for handling bit-extension of and operations with undef values
  // e.g. bitwise operations must 0-extend their arguments (even with undef msb)
  assign y0  = a +  1'bx;
  assign y1  = a -  1'bx;
  assign y2  = a *  1'bx;
  assign y3  = a /  1'bx;
  assign y4  = a %  1'bx;
  assign y5  = a >  1'bx;
  assign y6  = a >= 1'bx;
  assign y7  = a <  1'bx;
  assign y8  = a <= 1'bx;
  assign y9  = a && 1'bx;
  assign y10 = a || 1'bx;
  assign y11 = a == 1'bx;
  assign y12 = a != 1'bx;
  assign y13 = a &  1'bx;
  assign y14 = a |  1'bx;
  assign y15 = a ^  1'bx;
  assign y16 = a ^~ 1'bx;
  assign y17 = + 1'bx;
  assign y18 = - 1'bx;
endmodule
module issue_010(a, b, y);
  // http://forums.xilinx.com/t5/Synthesis/Vivado-creates-netlist-with-inputs-shorted-together/td-p/397161
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
  //
  // (when synthesized with (* use_dsp48 = "no" *) set on the module)

  wire [80:0] y0;
  wire [4:0] y1;
  wire [3:0] y2;

  output [89:0] y;
  assign y = {y0,y1,y2};

  assign y0  = 0;
  assign y1  = {4{{3{b}}}};
  assign y2  = 4'b1000 * a;
endmodule
module issue_011(a, y);
  // https://github.com/steveicarus/iverilog/issues/6
  input [0:0] a;
  output [0:0] y;
  // icarus verilog vpp (fixed in git d1c9dd5) asserts on this expression
  //   Internal error: Input vector expected width=1, got bit=2'b00, base=0, vwid=2
  assign y  = |(-a);
endmodule
module issue_012(a, y);
  // https://github.com/steveicarus/iverilog/issues/7
  input [3:0] a;
  output [3:0] y;
  // icarus verilog (git d1c9dd5) does not correctly propagate undef thru power
  // operator (y should be 4'bx when a is zero, but iverilog returns 4'd1).
  assign y = 4'd2 ** (4'd1/a);
endmodule
module issue_013(a, y);
  // https://github.com/steveicarus/iverilog/issues/8
  input signed [3:0] a;
  output [1:0] y;
  // icarus verilog (git d1c9dd5) evaluates bit-wise operations of signed values
  // to unsigned values when the arguments are constant. Thus "a = 0" yields
  // "y[0] = 0" in icarus verilog, even though it should be "y[1] = 1 (see
  // sec. 5.5.1 of IEEE Std 1365-2005). bitwise operations of variables or
  // variables with constants are implemented correctly. So y[1] always shows
  // the right value.
  assign y[0] = a > (4'sb1010 | 4'sd0);
  assign y[1] = (a | 4'sd0) > 4'sb1010;
endmodule
module issue_014(a, b, y);
  // http://forums.xilinx.com/t5/Synthesis/Vivado-GDpGen-implementDivMod-DFNode-bool-Assertion-TBD-failed/td-p/401721
  input [1:0] a;
  input [2:0] b;
  output [3:0] y;
  // Vivado 2013.4 asserts on this test case:
  // vivado: /.../gencore/dp/GDpGenDivMod.cc:324: void GDpGen::implementDivMod(DFNode*, bool): Assertion `TBD' failed.
  assign y = $signed(a / b);
endmodule
module issue_015(a, y);
  // http://forums.xilinx.com/t5/Synthesis/Vivado-bug-in-undef-handling-for-relational-operators/td-p/403469
  input [3:0] a;
  output [23:0] y;

  wire [3:0] y0;
  wire [3:0] y1;
  wire [3:0] y2;
  wire [3:0] y3;
  wire [3:0] y4;
  wire [3:0] y5;

  assign y = {y0,y1,y2,y3,y4,y5};

  // All this cases should evaluate to 4'b000x (regardless of the value of 'a').
  // But Vivado 2013.4 returns 4'b0010 instead.
  assign y0 = a >  4'bx;
  assign y1 = a >= 4'bx;
  assign y2 = a <  4'bx;
  assign y3 = a <= 4'bx;
  assign y4 = a == 4'bx;
  assign y5 = a != 4'bx;
endmodule
module issue_016(a, y);
  input [1:0] a;
  output [7:0] y;

  wire [3:0] y0;
  wire [3:0] y1;
  assign y = {y0,y1};

  // this should return zero (see table 5-5 of IEEE Std 1364-2005)
  // but it returns different values in quartus 13.1
  assign y0  = -4'd1 ** -4'sd2;
  assign y1  = -4'd1 ** -4'sd3;
endmodule
