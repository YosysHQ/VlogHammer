
Strange Verific bug with replicate and xor-reduce
=================================================

~CLOSED~ Verific 482_32_150519

The expression in this module is constant zero: Whatever the inner expression
evaluates to, the replication operator duplicates it, thus only yielding an
even number of set bits. The XOR-reduce is only true if the number of set bits
in the operand is odd.

    :::Verilog
    module issue_056(a, y);
      input [3:0] a;
      output [3:0] y;
    
      assign y = ^{2{{|1, |1 << a}}};
    endmodule

But Verific 463_32_140722 thinks that for example **a=0** yields **y=1**.

**History:**  
2014-07-25 Reported bug to Verific support  
2014-07-26 Bug added to issue tracker: VIPER Issue #8862  
2015-05-20 Fixed in Verific 482_32_150519  

