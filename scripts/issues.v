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
  output [167:0] y;

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
  wire [7:0] y16;
  wire [7:0] y17;
  wire [7:0] y18;
  wire [7:0] y19;
  wire [7:0] y20;
  assign y = {y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15,y16,y17,y18,y19,y20};

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
  localparam [7:0] ss16 = -8'sd2 ** +8'sd0;
  localparam [7:0] ss17 = -8'sd1 ** +8'sd0;
  localparam [7:0] ss18 = +8'sd0 ** +8'sd0;
  localparam [7:0] ss19 = +8'sd1 ** +8'sd0;
  localparam [7:0] ss20 = +8'sd2 ** +8'sd0;

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
  localparam [7:0] su16 = -8'sd2 ** +8'd0;
  localparam [7:0] su17 = -8'sd1 ** +8'd0;
  localparam [7:0] su18 = +8'sd0 ** +8'd0;
  localparam [7:0] su19 = +8'sd1 ** +8'd0;
  localparam [7:0] su20 = +8'sd2 ** +8'd0;

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
  localparam [7:0] us16 = -8'd2 ** +8'sd0;
  localparam [7:0] us17 = -8'd1 ** +8'sd0;
  localparam [7:0] us18 = +8'd0 ** +8'sd0;
  localparam [7:0] us19 = +8'd1 ** +8'sd0;
  localparam [7:0] us20 = +8'd2 ** +8'sd0;

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
  localparam [7:0] uu16 = -8'd2 ** +8'd0;
  localparam [7:0] uu17 = -8'd1 ** +8'd0;
  localparam [7:0] uu18 = +8'd0 ** +8'd0;
  localparam [7:0] uu19 = +8'd1 ** +8'd0;
  localparam [7:0] uu20 = +8'd2 ** +8'd0;

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
  assign y16 = a == 0 ? ss16 : a == 1 ? su16 : a == 2 ? us16 : uu16;
  assign y17 = a == 0 ? ss17 : a == 1 ? su17 : a == 2 ? us17 : uu17;
  assign y18 = a == 0 ? ss18 : a == 1 ? su18 : a == 2 ? us18 : uu18;
  assign y19 = a == 0 ? ss19 : a == 1 ? su19 : a == 2 ? us19 : uu19;
  assign y20 = a == 0 ? ss20 : a == 1 ? su20 : a == 2 ? us20 : uu20;
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
module issue_017(ctrl, y);
  input [1:0] ctrl;
  output [5:0] y;

  wire [2:0] y0;
  wire [2:0] y1;
  assign y = {y0,y1};

  // this should return 3'b001 but isim 14.7 returns 3'b000
  assign y0 = &($signed(2'b11));
  assign y1 = &($unsigned(2'b11));
endmodule
module issue_018(a, y);
  input [3:0] a;
  output [3:0] y;

  // in a localparam, like a wire, the width of the param should be
  // use to extend the expression. so this should be equal to ~4'b0001.
  // but isim 14.1 does not do this correctly.
  localparam [3:0] p = ~1'b1;
  assign y = p;
endmodule
module issue_019(a, y);
  input [0:0] a;
  output [15:0] y;

  wire [7:0] y0;
  wire [7:0] y1;
  assign y = {y0,y1};

  // according to table 5-6 of IEEE Std 1364-2005, the following expressions
  // should return 8'bx, but instead with ISIM 14.7 and XSIM 2013.4 they return 8'b0 instead.
  assign y0  = 8'sd0 ** -8'sd1;
  assign y1  = 8'd 0 ** -8'sd1;
endmodule
module issue_020(a, y);
  input [3:0] a;
  output [3:0] y;

  // xsim 2013.4 fails to recognize this as a signed expression and returns 4'b0110 instead of 4'b1110.
  localparam [3:0] p15 = 3'sb100 >>> 2'b01;
  assign y = p15;
endmodule
module issue_021(a, y);
  input [31:0] a;
  output [5:0] y;

  // icarus verilog (git d1c9dd5) takes forever to compile this expression because they do not
  // use an efficient Power-Modulus Algorithm to perform the calculation. (actually there are
  // two bugs: one in the compiler (ivl) and one in the simulator (vvp). But the simulator bug can't
  // be tested here because powers to something else than base 2 is not synthesizable.
  // see https://github.com/steveicarus/iverilog/issues/9
  assign y = 6'd3 ** 123456789;
endmodule
module issue_022(a, y);
  input [1:0] a;
  output [1:0] y;

  // icarus verilog (git 68f8de2) fails with the following internal error:
  //     internal error: lval-rval width mismatch: rval->vector_width()==1, lval->vector_width()==2
  //     assert: elaborate.cc:150: failed assertion rval->vector_width() >= lval->vector_width()
  assign y = 'bx ? 2'b0 : a;
endmodule
module issue_023(a, y);
  input [1:0] a;
  output [9:0] y;

  // icarus verilog (git b1ef099) allocates 16GB of memory to process this line
  localparam [4:0] p1 = 1'b1 << ~30'b0;

  // icarus verilog (git b1ef099) fails with an assert when trying to process this line:
  // ivl: verinum.cc:370: verinum::V verinum::set(unsigned int, verinum::V): Assertion 'idx < nbits_' failed.
  localparam [4:0] p2 = 1'b1 << ~40'b0;

  assign y = {p1, p2};
endmodule
module issue_024(a, y);
  input [0:0] a;
  output [0:0] y;

  // icarus verilog (git b1ef099) returns 1'b1 for this expression. it should be 1'bx.
  assign y = 1'b1 >= |1'bx;
endmodule
module issue_025(a, y);
  input [1:0] a;
  output [7:0] y;

  wire [3:0] y1;
  wire [3:0] y2;

  // icarus verilog (git 5a06602) returns 4'bxx00 instead of 4'bxxxx for the first expression.
  assign y1 = 4'bxx00 + 2'b00;
  assign y2 = 4'bxx00 + a;
  assign y = { y1, y2 };
endmodule
module issue_026(a, b, y);
  input [1:0] a;
  input [1:0] b;
  output [3:0] y;
  wire [1:0] y1;
  wire [1:0] y2;
  wire u = 1'bx;

  // Yosys prior to git commit ae5032a used to output 2'bxx instead of 2'b0x when a is active.
  assign y1 = a ? 1'bx : b;
  assign y2 = a ? u : b;
  assign y = { y1, y2 };
endmodule
module issue_027(a, b, c, y);
  input [0:0] a;
  input signed [2:0] b;
  input signed [3:0] c;
  output [5:0] y;

  // Yosys prior to git commit 9e99984 had a bug in sign extend for const_eval of this
  // expression, which showed up as a 'yosim' bug in vloghammer.
  assign y = a ? b : c;
endmodule
module issue_028(a, y);
  input [3:0] a;
  output [3:0] y;

  // icarus verilog (git a3450bf) returns 4'b0000 instead of 4'bxxxx.
  assign y = 4'b0 * 4'bx;
endmodule
module issue_029(a, y);
  input [3:0] a;
  output [7:0] y;
  wire [3:0] y1;
  wire [3:0] y2;

  assign y1 = 4'b1 << 33'h100000000;
  assign y2 = 1 >> {a, 64'b0};
  assign y = { y1, y2 };
endmodule
module issue_030(a, y);
  input [3:0] a;
  output [31:0] y;

  wire [3:0] y0;
  wire [3:0] y1;
  wire [3:0] y2;
  wire [3:0] y3;
  wire [3:0] y4;
  wire [3:0] y5;
  wire [3:0] y6;
  wire [3:0] y7;

  assign y = {y0,y1,y2,y3,y4,y5,y6,y7};

  assign y0 = 1'bx >> a;
  assign y1 = 1'bx << a;
  assign y2 = 1'bx >>> a;
  assign y3 = 1'bx <<< a;
  assign y4 = 1'sbx >> a;
  assign y5 = 1'sbx << a;
  assign y6 = 1'sbx >>> a;
  assign y7 = 1'sbx <<< a;
endmodule
module issue_031(a, y);
  input [2:0] a;
  output [2:0] y;
  assign y = { &{a,1'bx}, |{a,1'bx}, ^{a,1'bx} };
endmodule
module issue_032(a, b, y);
  input signed [3:0] a;
  input signed [3:0] b;
  output [3:0] y;

  // This expression is unsigned because of the 4'b0.
  // But icarus verilog (git 3e41a93) handles the expression as signed.
  assign y = (1 ? a : 4'b0) < (1 ? b : b);
endmodule
module issue_033(a, y);
  input [1:0] a;
  output [1:0] y;

  // This should return 2'b00 when a[1] is 1. But Verific 35_463_32_140306
  // sets y to constant 2'b0x instead.
  assign y = a == 1'bx;
endmodule
module issue_034(a, y);
  input [3:0] a;
  output [3:0] y;

  // This should return 4'b0000 or 4'b0001 but Verilator fb4928b returns
  // 4'b1111 or 4'b1110 instead.
  assign y = ~|a;
endmodule
module issue_035(a, y);
  input [3:0] a;
  output [5:0] y;

  // The term (p1 + p2) below is part of an unsigned expression and thus should
  // be zero-extended. Verilator fb4928b however performs signed bit extension
  // and thus returns an incorrect result.
  localparam signed [3:0] p1 = 4'b1000;
  localparam signed [3:0] p2 = 0;
  assign y = a + (p1 + p2);
endmodule
module issue_036(a, b, c, d, y);
  input [3:0] a;
  input [3:0] b;
  input [3:0] c;
  input [3:0] d;
  output [11:0] y;
  wire [3:0] y1;
  wire [3:0] y2;
  wire [3:0] y3;

  // This should return y=15 for a=15, b=15, c=15, d=15.
  // But Design Compiler G-2012.06-SP4 returns y=7 instead.
  assign y1 = a >>> ((b == c) >>> d);

  // This should return 1 but DC G-2012.06-SP4 returns 0 instead.
  assign y2 = (|1 >>> 1) == |0;

  // This should return 0 but DC G-2012.06-SP4 returns 1 instead.
  assign y3 = {|1 >>> 1};

  assign y = { y1, y2, y3 };
endmodule
module issue_037(a, b, y);
  input signed [4:0] a;
  input [2:0] b;
  output [3:0] y;

  // -- Verilator b631b59 returns 1 instead of 0 for a=-1 and b=7.
  assign y = |0 != (a >>> b);
endmodule
module issue_038(a, y);
  input [3:0] a;
  output [4:0] y;

  // -- Verilator a985a1f returns 11001 instead of 01001, i.e. verilator
  // performs sign extension even though the result of { .. } is unsigned.
  assign y = { -4'sd7 };
endmodule
module issue_039(a, y);
  input [3:0] a;
  output [3:0] y;

  // -- Verilator 4a58e85 creates the following error:
  // %Error: Internal Error: ../V3Number.cpp:521: toUInt with 4-state 4'bxxxx
  assign y = a >>> 4'bx;
endmodule
module issue_040(a, y);
  input [3:0] a;
  output [3:0] y;

  // -- Verilator 621c515 creates code that uses the undeclared function VL_POW_WWI()
  assign y = 65'd2 ** a;
endmodule
module issue_041(a, y);
  input [2:0] a;
  output [3:0] y;

  // This should effectively be y=0, but verilator 1f56312 evaluates y=a instead.
  assign y = (a >> 2'b11) >> 1;
endmodule
module issue_042(a, y);
  input [3:0] a;
  output [3:0] y;
  localparam [3:0] p11 = 1'bx;

  // This should set y=1, but verilator 6ce2a52 sets y=0 instead.
  assign y = ~&p11;
endmodule
module issue_043(a, y);
  input signed [7:0] a;
  output [15:0] y;

  // -- Verilator 5f5a3db creates C code that segfaults for a=128.
  assign y = {3{{~22'd0}}} <<< {4{a}};
endmodule
module issue_044(a, y);
  input [3:0] a;
  output [3:0] y;

  // Yosys f69b580 returns y=1 instead of y=0 for a=15.
  assign y = &(0 ? 0 : (&a));
endmodule
module issue_045(a, y);
  input signed [15:0] a;
  output [15:0] y;

  // -- Verilator d7e4bc1 fails on this code:
  // %Error: Verilator internal fault, sorry.  Consider trying --debug --gdbbt
  assign y = (a >> 16) >>> 32'h7ffffff1;
endmodule
module issue_046(a, y);
  input signed [3:0] a;
  output [3:0] y;

  // This should set y=4'b1111 but Verilator d7e4bc1 sets y=4'b0001 instead.
  assign y = $signed(5'd1 > a-a);
endmodule
module issue_047(a, b, y);
  input signed [0:0] a;
  input signed [1:0] b;
  output [1:0] y;

  // For a='b1 and b='b11 this should output y='b00 (because a='b1 is
  // sign-extended to a='b11). But Yosys 0.7+205 (git sha1 7d2fb6e)
  // after optimizations outputs y='b10 instead.

  assign y = b ^ (a|a);
endmodule
module issue_048(a, b, y);
  input [1:0] a;
  input [2:0] b;
  output [3:0] y;

  // For "b != 0" this should return "y[3:2] == 0". But iverilog 020e280 returns "y[3:2] == y[1:0]" instead.
  assign y = {a >> {22{b}}, a << (0 <<< b)};
endmodule
module issue_049(a, y);
  input [3:0] a;
  output [3:0] y;

  // -- Verilator 06744b6 creates the following error:
  // %Error: Internal Error: ../V3Number.cpp:521: toUInt with 4-state 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  assign y = a << 1 <<< 0/0;
endmodule
module issue_050(a, y);
  input [4:0] a;
  output [4:0] y;

  // This should return y=0 for a=31, but Verilator 06744b6 returns y=31 instead
  assign y = a >> ((a ? 1 : 2) << a);
endmodule
module issue_051(a, b, y);
  // PATTERN: 10'h163
  input [3:0] a;
  input [5:0] b;
  output [3:0] y;

  // For a=5, b=35 this should return y=0, but Verilator f705f9b returns y=8 instead
  assign y = 64'd0 | (a << b);
endmodule
module issue_052(a, y);
  input [0:0] a;
  output [3:0] y;

  // -- Verilator f705f9b prints "%Error: rtl.v:4: Unsupported: 4-state numbers in this context"
  // for the following line. But for example "(0/0) % 0" is accepted.
  assign y = ((0/0) ? 1 : 2) % 0;
endmodule
module issue_053(a, y);
  input [3:0] a;
  output [3:0] y;

  // This should always return y=4'b1111, but Verilator f705f9b only does this for a=0.
  assign y = (a >> a) ^~ (a >> a);
endmodule
module issue_054(a, y);
  input signed [1:0] a;
  output [63:0] y;

  wire [7:0] y0;
  wire [7:0] y1;
  wire [7:0] y2;
  wire [7:0] y3;
  wire [7:0] y4;
  wire [7:0] y5;
  wire [7:0] y6;
  wire [7:0] y7;
  assign y = {y0,y1,y2,y3,y4,y5,y6,y7};

  // This is an extended version of issue_000.
  // Verific 35_463_32_140722 passes issue_000 but not this version.

  assign y0 = {1'sb1};
  assign y1 = {1{1'sb1}};
  assign y2 = {1'sb1, 1'sb1};
  assign y3 = {2{1'sb1}};
  assign y4 = {a};
  assign y5 = {1{a}};
  assign y6 = {a, a};
  assign y7 = {2{a}};
endmodule
module issue_055(a, b, y);
  input [1:0] a;
  input [3:0] b;
  output [3:0] y;

  // The self determined size of a division is max(SIZE(left), SIZE(right)).
  // (see IEEE Std. 1364-2005 table 5-22 or IEEE Std. 1800-2012 table 11-21)
  //
  // Because of this the following expression is constant 0: The division returns
  // a selft-determined expression that is 4 bits in size and has the two MSB set
  // to constant zero.
  //
  // It looks like Verific 35_463_32_140722 uses only SIZE(left), thus evaluating
  // a=2'b11 and b=2'b01 to y=4'b0001.

  assign y = &(a / b);
endmodule
module issue_056(a, y);
  input [3:0] a;
  output [3:0] y;

  // This expression is constant zero: Whatever the inner expression evaluates to,
  // the replication operator duplicates it, thus only yielding an even number of
  // set bits. The XOR-reduce is only true if the number of set bits in the operand
  // is odd.
  //
  // But Verific 35_463_32_140722 thinks that for example a=0 yields y=1.

  assign y = ^{2{{|1, |1 << a}}};
endmodule
module issue_057(a, y);
  input [2:0] a;
  output [3:0] y;

  // this is expected to set y[3:1] = 'b100 for a = 1.
  // but verilator_3_864 sets y[3:1] = 'b000 instead.

  localparam [5:15] p = 51681708;
  assign y = p[15 + a -: 5];
endmodule
module issue_058(a, y);
  input [1:0] a;
  output [3:0] y;

  // this is expected to set y[3:1] = {2'b01, a[1]} and y[0] = don't care,
  // but Vivado 2018.3 generates y[3:1] = {2'b1z, a[1]}.

  wire [1:0] y0;
  wire [1:0] y1;
  assign y = {y0,y1};

  localparam [1:0] p1 = 1;
  localparam [1:0] pX = 1 % 0;

  assign y0 = a ? p1 : p1;
  assign y1 = a ^ (a != pX);
endmodule
module issue_059(a, y);
  input [2:0] a;
  output [3:0] y;

  // This seems to hang Vivado 2018.3 forever.

  assign y = a % 1'bx;
endmodule
