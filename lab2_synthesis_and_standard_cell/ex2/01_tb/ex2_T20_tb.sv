// 01_tb/ex2_T20_tb.sv
`timescale 1ns/1ps

`ifdef GATE_LEVEL
  // Netlist sau tổng hợp
  `include "./03_outputs/ex2_netlist_s1v2h.sv"
  `include "./gpdk045_verilog/slow_vdd1v2_basicCells_hvt.v"
`else
  // RTL
  `include "./00_src/alu.sv"     // nếu file của bạn tên khác thì sửa lại
`endif

module ex2_T20_tb;

  // ==== Thời gian giữa 2 vector ====
  localparam int T = 20; // ns

  // ==== Tín hiệu DUT ====
  logic [1:0] A, B, S;
  logic [1:0] Y;

  // ==== Reference và đếm lỗi ====
  logic [1:0] refY;
  int         err_cnt;

  // ==== DUT ====
  // Nếu top của bạn là ex2 thì đổi alu -> ex2
  alu DUT (
    .A (A),
    .B (B),
    .S (S),
    .Y (Y)
  );

  // ==== SDF annotation (nếu mô phỏng annotated) ====
  `ifdef ANNOTATION
    initial
      $sdf_annotate("./03_outputs/ex2_delay_s1v2h.sdf",
                    DUT, , "annotate_ex2_T20.log", "MAXIMUM");
  `endif

  // ==== Dump waveform ====
  initial begin
    $dumpfile("ex2_T20_wave.vcd");
    $dumpvars(0, ex2_T20_tb.DUT);
  end

  // ==== Task: áp vector + check và in PASS/FAIL ====
  task automatic apply_and_check(
    input int          idx,
    input logic [1:0]  ts,
    input logic [1:0]  ta,
    input logic [1:0]  tb
  );
  begin
    // Gán input
    S = ts;
    A = ta;
    B = tb;

    // Chờ cho mạch ổn định (nếu có delay)
    #T;

    // Tính giá trị đúng (reference, không delay)
    unique case (ts)
      2'b00: refY = ta + tb;
      2'b01: refY = ta - tb;
      2'b10: refY = ta & tb;
      2'b11: refY = ta | tb;
      default: refY = 2'b00;
    endcase

    // So sánh và in kết quả từng trường hợp
    if (Y === refY) begin
      $display("[CASE %0d] PASS : S=%b A=%b B=%b -> Y=%b",
               idx, S, A, B, Y);
    end else begin
      err_cnt++;
      $display("[CASE %0d] *** FAIL *** : S=%b A=%b B=%b -> Y=%b, expected=%b",
               idx, S, A, B, Y, refY);
    end
  end
  endtask

  // ==== Kịch bản mô phỏng ====
  initial begin
    // Khởi tạo
    A = 2'b00;
    B = 2'b00;
    S = 2'b00;
    refY   = 2'b00;
    err_cnt = 0;

    #5; // cho ổn định một chút

    // Áp các vector theo bảng đề
    //   idx   S      A      B
    apply_and_check(0, 2'b00, 2'b01, 2'b00);
    apply_and_check(1, 2'b00, 2'b11, 2'b01);
    apply_and_check(2, 2'b01, 2'b11, 2'b00);
    apply_and_check(3, 2'b01, 2'b11, 2'b11);
    apply_and_check(4, 2'b10, 2'b11, 2'b01);
    apply_and_check(5, 2'b10, 2'b01, 2'b10);
    apply_and_check(6, 2'b11, 2'b11, 2'b01);
    apply_and_check(7, 2'b11, 2'b01, 2'b10);

    // ==== Tổng kết ====
    if (err_cnt == 0) begin
      $display("====================================");
      $display(" ex2_T20_tb : ALL CASES PASSED");
      $display("====================================");
    end else begin
      $display("====================================");
      $display(" ex2_T20_tb : TEST FAILED with %0d errors", err_cnt);
      $display("====================================");
    end

    $finish;
  end

endmodule
