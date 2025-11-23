// 01_tb/ex1_nand2_tb.sv
`timescale 1ns/1ps

`ifdef GATE_LEVEL
  `include "./03_outputs/nand2/nand2_netlist_f1v0h.sv"           // (đổi theo corner)
  `include "./gpdk045_verilog/fast_vdd1v0_basicCells_hvt.v"      // (đổi theo corner)
`else
  `include "./00_src/ex1_nand2.sv"
`endif

module ex1_nand2_tb;
  logic A, B;
  logic Y;

  nand2 DUT (.A(A), .B(B), .Y(Y));

  `ifdef ANNOTATION
    initial $sdf_annotate("./03_outputs/nand2/nand2_delay_f1v0h.sdf", // (đổi theo corner)
                           DUT, , "annotate.log", "MAXIMUM");
  `endif

  initial begin
    $dumpfile("nand.vcd");
    $dumpvars(0, ex1_nand2_tb.DUT);
  end

  initial begin
          A=0; B=1;
    #0.1  A=1;     //do Y fall            
    #0.3  A=0;     //do Y raise
 
    #0.3  A=1; B=0;
    #0.3  B=1;     //do Y fall
    #0.3  B=0;     //do Y raise

    #0.2  $finish;
  end
endmodule
