
Icarus Verilog creates huge in-memory arrays for shifts with large rhs
======================================================================

~CLOSED~ Icarus GIT 5dcd2e8

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
2014-02-25 Fixed in GIT commit [5dcd2e8](https://github.com/steveicarus/iverilog/commit/5dcd2e89570a7704027f17238ddced9bc710aa28)  
