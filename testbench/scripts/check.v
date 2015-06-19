module check;

reg [`input_bits-1:0] in_v;
wire [`output_bits-1:0] out_v;
reg [`output_bits-1:0] out_bits, out_dc;
`module_name uut (`module_args);

integer file, r, k;
integer count = 0;
reg found_error = 0;

initial begin
`ifdef REFDAT_FN
  file = $fopen(`REFDAT_FN, "r");
`else
  file = $fopen("refdat.txt", "r");
`endif

  for (r = $fscanf(file, "%x %x %x\n", in_v, out_bits, out_dc); r == 3; r = $fscanf(file, "%x %x %x\n", in_v, out_bits, out_dc)) begin
    #1000;
`ifdef MATCH_DC
    if (out_v !== (out_bits ^ (out_dc & `output_bits'bx)))
`else
    if ((out_dc | out_bits) !== (out_dc | out_v))
`endif
    begin
      $display("found fail pattern: %x", in_v);
      $display("  expected: %b", out_bits ^ (out_dc & `output_bits'bx));
      $display("       got: %b", out_v);
      $write("            ");
      for (k = `output_bits-1; k >= 0; k = k-1)
`ifdef MATCH_DC
        if (out_v[k] !== (out_bits[k] ^ (out_dc[k] & 1'bx)))
`else
        if ((out_dc[k] | out_bits[k]) !== (out_dc[k] | out_v[k]))
`endif
          $write("^");
	else
          $write(" ");
      $display("");
      found_error = 1;
    end
    count = count+1;
  end

  if (found_error)
    $display("++ERROR++ At least one fail pattern found.");
  if (count != 1000)
    $display("++ERROR++ Incorrect number of records read from refdat.txt.");
  if (!found_error && count == 1000)
    $display("++OK++");

  $fclose(file);
end

endmodule
