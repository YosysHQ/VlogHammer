
Verilator uses undeclared helper function for power op > 64 bits
================================================================

~OPEN~ Verilator 3_906

Verilator 621c515 creates code that uses the undeclared function `VL_POW_WWI`:

    :::Verilog
    module issue_040(a, y);
      input [3:0] a;
      output [3:0] y;
      assign y = 65'd2 ** a;
    endmodule

The gcc error message is:

    Vissue_040.cpp: In static member function `static void Vissue_040::_combo__TOP__1(Vissue_040__Syms*)':
    Vissue_040.cpp:83:63: error: `VL_POW_WWI' was not declared in this scope
         VL_POW_WWI(65,65,4, __Vtemp3, __Vtemp2, (IData)(vlTOPp->a));

**History:**  
2014-05-05 Reported as [Issue #761](http://www.veripool.org/issues/761-Verilator-Verilator-uses-undeclared-helper-function-for-power-op-64-bits)  
2017-07-01 Still broken in Verilator GIT 1da5a33 (3_906)  
