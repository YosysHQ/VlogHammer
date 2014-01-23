
Icarus Verilog vvp asserts on reduce of one-bit .arith/sub
==========================================================

~CLOSED~ Icarus GIT d1c9dd5

The following module builds fine with iverilog (ivl) but triggers an assert in vvp:

    :::Verilog
    module issue_011(a, y);
        input [0:0] a;
        output [0:0] y;
        assign y  = |(-a);
    endmodule

The error I get is:

    Internal error: Input vector expected width=1, got bit=2'b00, base=0, vwid=2
    vvp: vvp_net_sig.cc:896: virtual vvp_net_fil_t::prop_t vvp_wire_vec4::filter_vec4(const vvp_vector4_t&,
    		vvp_vector4_t&, unsigned int, unsigned int): Assertion `bits4_.size() == vwid' failed.

**History:**  
2013-12-31 [Reported](https://github.com/steveicarus/iverilog/issues/6) bug on GitHub  
2014-01-06 Fixed in GIT commit [d1c9dd5](https://github.com/steveicarus/iverilog/commit/d1c9dd554bfd09813a27fec3ab3b3f9fe40f376a)  

