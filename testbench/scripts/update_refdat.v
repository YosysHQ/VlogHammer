module update_refdat;

reg [`input_bits-1:0] in_v;
wire [`output_bits-1:0] out_v;
`module_name uut (`module_args);

integer file;

task store_pattern;
  reg [`output_bits-1:0] out_bits, out_dc;
  integer i;
  begin
    #1000;
    for (i = 0; i < `output_bits; i = i+1)
      if (out_v[i] === 1'b0 || out_v[i] === 1'b1)
        { out_bits[i], out_dc[i] } = { out_v[i], 1'b0 };
      else
        { out_bits[i], out_dc[i] } = 2'b01;
    $fdisplay(file, "%x %x %x", in_v, out_bits, out_dc);
  end
endtask

reg [63:0] xorshift64_state = 64'd88172645463325252;

task xorshift64_next;
  begin
    // see page 4 of Marsaglia, George (July 2003). "Xorshift RNGs". Journal of Statistical Software 8 (14).
    xorshift64_state = xorshift64_state ^ (xorshift64_state << 13);
    xorshift64_state = xorshift64_state ^ (xorshift64_state >>  7);
    xorshift64_state = xorshift64_state ^ (xorshift64_state << 17);
  end
endtask

integer iter;
integer offset;

initial begin
  file = $fopen("refdat.txt", "w");

  in_v = 0;
  store_pattern;

  in_v = ~0;
  store_pattern;

  for (iter = 2; iter < 1000; iter = iter+1) begin
    in_v = 0;
    for (offset = 0; offset < `input_bits; offset = offset+16) begin
    	in_v = in_v | (xorshift64_state[15:0] << offset);
	xorshift64_next;
    end
    store_pattern;
  end

  $fclose(file);
end

endmodule
