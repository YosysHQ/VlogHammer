module VERIFIC_FADD (cin, a, b, cout, o);
  input cin, a, b;
  output cout, o;
  assign {cout, o} = cin + a + b;
endmodule
