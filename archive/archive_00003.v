module archive_00003(a0, a1, a2, a3, a4, a5, b0, b1, b2, b3, b4, b5, y);
  input [3:0] a0;
  input [4:0] a1;
  input [5:0] a2;
  input signed [3:0] a3;
  input signed [4:0] a4;
  input signed [5:0] a5;

  input [3:0] b0;
  input [4:0] b1;
  input [5:0] b2;
  input signed [3:0] b3;
  input signed [4:0] b4;
  input signed [5:0] b5;

  wire [3:0] y0;
  wire [4:0] y1;
  wire [5:0] y2;
  wire signed [3:0] y3;
  wire signed [4:0] y4;
  wire signed [5:0] y5;

  output [30:0] y;
  assign y = {y0,y1,y2,y3,y4,y5};

  assign y0 = $unsigned((($unsigned(b0))));
  assign y1 = ((+(+b3))==(~^(a3<<a3)));
  assign y2 = ((((a4^b0)<<(b0!=a4))<<<((a2*b0)==(a0<<<a2)))&(((b3!==b3)>>>(b3^a5))<<<((a1^~b0)&(b0>>>a1))));
  assign y3 = (((a1^b5)-(a1+b1))>>>((a2==b3)>(a0^a2)));
  assign y4 = (((~^(~^((-(b2!==b1))!==(a1>>b5))))^~(+$signed(((~|(!$unsigned((+a3)))))))));
  assign y5 = $unsigned((&$signed((^$signed((($unsigned(b2))))))));
endmodule
