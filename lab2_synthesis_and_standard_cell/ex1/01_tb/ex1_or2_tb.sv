// 01_tb/ex1_or2_tb.sv
`timescale 1ns/1ps

// ======= chọn rtl hay gatelevel =====
`ifdef GATE_LEVEL
  `include "./03_outputs/or2/or2_netlist_f1v2l.sv"               // (đổi theo corner)
  `include "./gpdk045_verilog/fast_vdd1v2_basicCells_lvt.v"      // (đổi theo corner)
`else
  `include "./00_src/ex1_or2.sv"
`endif

module ex1_or2_tb;
  logic A, B;
  logic Y;

  or2 DUT (.A(A), .B(B), .Y(Y));

  // ======= SDF back-annotation (khi GATE_LEVEL) =======
  `ifdef ANNOTATION
    initial $sdf_annotate("./03_outputs/or2/or2_delay_f1v2l.sdf", // (đổi theo corner)
                           DUT, , "annotate.log", "MAXIMUM");
  `endif

  // Ghi sóng
  initial begin
    $dumpfile("or2.vcd");
    $dumpvars(0, ex1_or2_tb.DUT);
  end

  // kich mau
  initial begin
          A=0; B=0;
    #0.1  A=1;     //A tu 0->1, xem Y rise
    #0.3  A=0;     //A tu 1->0, xem Y fall

    #0.3  B=1;     //B tu 0->1, xem Y rise
    #0.3  B=0;     //B tu 1->0, XEM y fall

    #0.2  $finish;
  end
endmodule
