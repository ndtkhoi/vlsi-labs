// 01_tb/ex4_T50_tb.sv
`timescale 1ns/1ps

`ifdef GATE_LEVEL
  `include "./03_outputs/ex4_netlist_s1v2h.sv"
  `include "./gpdk045_verilog/slow_vdd1v2_basicCells_hvt.v"
`else
  `include "./00_src/ex4.sv"
`endif

module ex4_T50_tb;

  localparam int T = 50;   // ns

  logic       clk;
  logic       rst;
  logic [1:0] Q;

  // Reference model
  logic [1:0] refQ;
  logic [1:0] expectedQ;
  int         cycle_cnt;
  int         err_cnt;

  // DUT
  ex4 DUT (
    .clk (clk),
    .rst (rst),
    .Q   (Q)
  );

  // SDF annotation (nếu dùng gate-level + delay)
  `ifdef ANNOTATION
    initial
      $sdf_annotate("./03_outputs/ex4_delay_s1v2h.sdf",
                    DUT, , "annotate_ex4_T50.log", "MAXIMUM");
  `endif

  // Dump waveform
  initial begin
    $dumpfile("ex4_T50_wave.vcd");
    $dumpvars(0, ex4_T50_tb.DUT);
  end

  // Clock
  initial begin
    clk = 0;
    forever #(T/2) clk = ~clk;
  end

  // Init reference & counters
  initial begin
    refQ      = 2'b00;
    cycle_cnt = 0;
    err_cnt   = 0;
  end

  // Stimulus + kết luận PASS/FAIL
  initial begin
    rst = 1;

    // Giữ reset trong 2 chu kỳ clock
    repeat (2) @(posedge clk);
    @(negedge clk);
    rst = 0;

    // Chạy thêm 10 chu kỳ để kiểm tra
    repeat (10) @(posedge clk);

    #(T/2);  // cho Q ổn định chu kỳ cuối

    if (err_cnt == 0) begin
      $display("====================================");
      $display(" ex4_T50_tb : TEST PASSED (no error)");
      $display("====================================");
    end 
    else begin
      $display("====================================");
      $display(" ex4_T50_tb : TEST FAILED with %0d errors", err_cnt);
      $display("====================================");
    end

    $finish;
  end

  // Reference model + checker
  always @(posedge clk) begin
    cycle_cnt++;

    // Cập nhật reference counter
    if (rst) begin
      expectedQ <= 2'b00;
      refQ      <= 2'b00;
    end
    else begin
  //sau reset: moi chu ky Q tang 1
      expectedQ <= refQ + 2'b01;
      refQ <= refQ + 2'b01;
   end

    // So sánh sau 1ns (cho Q có thời gian cập nhật, nhất là khi gate-level + SDF)
   
    if (!rst) begin
      if (Q !== expectedQ) begin
        err_cnt++;
        $display("[%0t] ERROR (T=50): cycle %0d: expected Q=%b, got Q=%b",
                 $time, cycle_cnt, expectedQ, Q);
      end
    end
  end

  endmodule
