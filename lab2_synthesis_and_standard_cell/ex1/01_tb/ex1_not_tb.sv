// 01_tb/ex1_not_tb.sv
`timescale 1ns/1ps

// ======= Chọn RTL hay Gate-level =======
`ifdef GATE_LEVEL
  // Netlist của cell NOT 
  `include "./03_outputs/not/not_netlist_f1v2l.sv"
  // Functional view của standard-cell lib 
  `include "./gpdk045_verilog/fast_vdd1v2_basicCells_lvt.v"
`else
  // RTL
  `include "./00_src/ex1_not.sv"
`endif

module ex1_not_tb;
  logic A, Y;

  // 
  not1 DUT (.A(A), .Y(Y));

  // Back-annotate SDF khi chạy GLS
  `ifdef ANNOTATION
    initial begin
      $sdf_annotate("./03_outputs/not/not_delay_f1v2l.sdf",
                    DUT, , "annotate.log", "MAXIMUM");
    end
  `endif

  // Ghi sóng
  initial begin
    $dumpfile("not.vcd");
    $dumpvars(0, ex1_not_tb.DUT);
  end

  // Kích xung đơn giản
  initial begin
    #0.0  A = 0;
    #0.1  A = 1;
    #0.1  A = 0;
    #0.1  A = 1;
    #0.1  $finish;
  end
endmodule
