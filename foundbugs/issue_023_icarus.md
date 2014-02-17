
Icarus Verilog creates huge in-memory arrays for shifts with large rhs
======================================================================

~OPEN~ Icarus GIT b1ef099

Icarus Verilog (git b1ef099) allocates 16 GB of memory when processing the following statement:

    :::Verilog
    module issue_023;
      localparam [4:0] p = 1'b1 << ~30'b0;
    endmodule

Adding another 10 bits to the RHS triggers an assert: `ivl: verinum.cc:370:
verinum::V verinum::set(unsigned int, verinum::V): Assertion 'idx < nbits_'
failed`:

    :::Verilog
    module issue_023;
      localparam [4:0] p = 1'b1 << ~40'b0;
    endmodule

**History:**  
2014-02-17 [Reported](https://github.com/steveicarus/iverilog/issues/13) bug on GitHub  

