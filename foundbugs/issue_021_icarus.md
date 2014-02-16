
Icarus Verilog efficiency of verinum and vpp_net pow() functions
================================================================

~CLOSED~ Icarus GIT 66bdbb7

Modules such as

    :::Verilog
    module test(y);
      output [5:0] y;
      assign y = 6'd3 ** 123456789;
    endmodule

take forever to compile because the verinum pow() function (in [verinum.cc](https://github.com/steveicarus/iverilog/blob/master/verinum.cc)) is
actually using a loop to evaluate the power:

    :::C
    for (long idx = 1 ;  idx < pow_count ;  idx += 1)
        result = result * left;

(For exponents that do not fit into a long long this would also return
incorrect values, but I think no-one would wait for such a case to finish
compiling..)

This should of course be instead calculated using a [Power-Modulus Algorithm](http://en.wikipedia.org/wiki/Modular_exponentiation).
See the const_pow() function in Yosys ([kernel/calc.cc](https://github.com/cliffordwolf/yosys/blob/master/kernel/calc.cc)) for an example implementation.

The vvp_net pow() function (in [vvp/vvp_net.cc](https://github.com/steveicarus/iverilog/blob/master/vvp/vvp_net.cc)) seems to implement a power-modulus algorithm but nevertheless the following code snippet hangs vvp:

    :::Verilog
    module test(a, y);
      input [5:0] a;
      output [5:0] y;
      assign a = 3;
      assign y = a ** 123456789;
    endmodule

PS: the examples above should evaluate to

    :::Verilog
    assign y = 6'b110011;

**History:**  
2014-01-06 [Reported](https://github.com/steveicarus/iverilog/issues/9) bug on GitHub  
2014-02-16 Fixed in GIT commit [66bdbb7](https://github.com/steveicarus/iverilog/commit/66bdbb77eca799a4e3762f4ae1ea420dd4269bf4)  

