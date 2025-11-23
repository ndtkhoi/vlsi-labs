`timescale 1ns/1ps

// Module accumulator8bit_addsub_tb - by NGUYEN DINH TRONG KHOI
// Purpose: Auto description placeholder for accumulator8bit_addsub_tb
module accumulator8bit_addsub_tb;
  // ===== Cấu hình kiểm cờ =====
  // 0: không kiểm carry/overflow (chỉ kiểm S)
  // 1: carry_expect = Cout (adder carry-out)
  // 2: carry_expect = ~Cout (một số flow mapping C = no-borrow)
  localparam int FLAG_MODE        = 0;   
  localparam int FLAG_LAT_STAGES  = 1;  

  // ===== Tín hiệu =====
  logic        clk;
  logic        rst_n;
  logic        add_sub;
  logic [7:0]  A;
  logic [7:0]  S;
  logic        carry;
  logic        overflow;

  // ===== DUT =====
  ex2 dut(
    .clk(clk),
    .rst_n(rst_n),
    .add_sub(add_sub),
    .A(A),
    .S(S),
    .carry(carry),
    .overflow(overflow)
  );

  // ===== Clock =====
  initial clk = 1'b0;
  always #5 clk = ~clk;
  task tick; begin @(posedge clk); #1; end endtask

  // ===== Kéo rộng xung để nhìn rõ trên sóng =====
  logic carry_wide, overflow_wide; int cw=0, vw=0;
  always @(posedge clk) begin
    if (carry)    cw <= 3; else if (cw>0) cw <= cw-1;
    if (overflow) vw <= 3; else if (vw>0) vw <= vw-1;
    carry_wide    <= (cw>0);
    overflow_wide <= (vw>0);
  end

  // ===== Mô hình tham chiếu: pipeline =====
  byte ref_Sq;
  byte in_Aq;
  bit  in_addsub_q;

  // pipeline cờ tham chiếu (Cout/ ~Cout) và overflow
  bit co_pipe [0:3];
  bit co_inv_pipe [0:3];
  bit ov_pipe [0:3];

  // Hàm 1 chu kỳ adder/sub
  function automatic void adder_cycle(
    input  byte Sq_i, input byte Aq_i, input bit addsub_i,
    output byte Snext_o, output bit cout_o, output bit ovf_o
  );
    // Bx = A  hoặc ~A (khi trừ), cin = addsub
    byte Bx = addsub_i ? ~Aq_i : Aq_i;
    int  sum = (Sq_i & 8'hFF) + (Bx & 8'hFF) + (addsub_i ? 1 : 0);
    Snext_o = sum[7:0];
    cout_o  = (sum >> 8) & 1;                // Cout unsigned
    // Overflow hai’s-complement: cộng hai số cùng dấu ra khác dấu
    ovf_o   = ((Sq_i[7] == Bx[7]) && (Snext_o[7] != Sq_i[7]));
  endfunction

  // In trạng thái (không access net nội bộ)
  task display_status(input string note);
    $display("Time=%0t | %s | add_sub=%0b  A=%0d (0x%02h)  S=%0d (0x%02h)  carry=%0b overflow=%0b",
             $time, note, add_sub, $signed(A), A, $signed(S), S, carry, overflow);
  endtask

  // So sánh theo mode
  task automatic check_flags(string tag);
    if (FLAG_MODE == 0) begin
      $display("[%s] (SKIP) CARRY=%0b OVERFLOW=%0b", tag, carry, overflow);
    end
    else if (FLAG_MODE == 1) begin
      if (carry !== co_pipe[FLAG_LAT_STAGES])
        $error("[%s] CARRY mismatch: got %0b exp %0b", tag, carry, co_pipe[FLAG_LAT_STAGES]);
      else
        $display("[%s] PASS CARRY=%0b", tag, carry);

      if (overflow !== ov_pipe[FLAG_LAT_STAGES])
        $error("[%s] OVERFLOW mismatch: got %0b exp %0b", tag, overflow, ov_pipe[FLAG_LAT_STAGES]);
      else
        $display("[%s] PASS OVERFLOW=%0b", tag, overflow);
    end
    else begin // FLAG_MODE == 2  (so ~Cout)
      if (carry !== co_inv_pipe[FLAG_LAT_STAGES])
        $error("[%s] CARRY mismatch (~Cout): got %0b exp %0b", tag, carry, co_inv_pipe[FLAG_LAT_STAGES]);
      else
        $display("[%s] PASS CARRY=%0b (~Cout)", tag, carry);

      if (overflow !== ov_pipe[FLAG_LAT_STAGES])
        $error("[%s] OVERFLOW mismatch: got %0b exp %0b", tag, overflow, ov_pipe[FLAG_LAT_STAGES]);
      else
        $display("[%s] PASS OVERFLOW=%0b", tag, overflow);
    end
  endtask

  // Một bước kiểm tra
  task automatic step_and_check(string tag, bit set_addsub, byte set_A);
    byte s_exp; bit c_now, v_now;
    // 1) Tính s_exp, c_now, v_now cho chu kỳ hiện tại
    adder_cycle(ref_Sq, in_Aq, in_addsub_q, s_exp, c_now, v_now);

    // 2) Áp input cho chu kỳ kế
    add_sub = set_addsub; A = set_A;

    // 3) Tick + in trạng thái
    tick(); display_status(tag);

    // 4) Check S
    if (S !== s_exp) $error("[%s] S mismatch: got 0x%0h exp 0x%0h", tag, S, s_exp);
    else             $display("[%s] PASS S=0x%0h", tag, S);

    // 5) Check cờ theo mode
    check_flags(tag);

    // 6) Cập nhật mô hình & pipeline cho chu kỳ kế
    ref_Sq      = s_exp;
    in_Aq       = set_A;
    in_addsub_q = set_addsub;

    co_pipe[3]     <= co_pipe[2];
    co_pipe[2]     <= co_pipe[1];
    co_pipe[1]     <= co_pipe[0];
    co_pipe[0]     <= c_now;

    co_inv_pipe[3] <= co_inv_pipe[2];
    co_inv_pipe[2] <= co_inv_pipe[1];
    co_inv_pipe[1] <= co_inv_pipe[0];
    co_inv_pipe[0] <= ~c_now;

    ov_pipe[3]     <= ov_pipe[2];
    ov_pipe[2]     <= ov_pipe[1];
    ov_pipe[1]     <= ov_pipe[0];
    ov_pipe[0]     <= v_now;
  endtask

  // Reset + prime
  task automatic do_reset_and_prime(input string why);
    $display("=== RESET: %s ===", why);
    add_sub = 1'b0; A = 8'h00;
    rst_n = 1'b0; repeat(3) @(posedge clk);
    display_status("ĐANG RESET");
    #2 rst_n = 1'b1; #1;
    tick(); display_status("NHẢ RESET");

    // Clear ref
    ref_Sq = 0; in_Aq = 0; in_addsub_q = 0;
    co_pipe      = '{default:0};
    co_inv_pipe  = '{default:0};
    ov_pipe      = '{default:0};

    // prime 2 NOP
    step_and_check("PRIME#1", 1'b0, 8'h00);
    step_and_check("PRIME#2", 1'b0, 8'h00);
  endtask

  // ===== Test plan (giữ nguyên như bạn đang dùng) =====
  initial begin
    clk=0; rst_n=0; add_sub=0; A=8'h00;
    $display("=== KIỂM TRA BỘ TÍCH LŨY VỚI CHỨC NĂNG CỘNG VÀ TRỪ ===");

    // Cụm 1
    do_reset_and_prime("Đầu bài");
    $display("\n=== KIỂM TRA PHÉP CỘNG CƠ BẢN ===");
    step_and_check("ADD +10",         1'b0, 8'd10);
    step_and_check("ADD +15",         1'b0, 8'd15);
    step_and_check("ADD +240(carry)", 1'b0, 8'd240);
    step_and_check("ADD +100",        1'b0, 8'd100);
    step_and_check("ADD +70",         1'b0, 8'd70);

    // Cụm 2
    $display("\n=== RESET VÀ KIỂM TRA PHÉP CỘNG LỚN ===");
    do_reset_and_prime("ADD lớn");
    step_and_check("ADD +112",        1'b0, 8'd112);
    step_and_check("ADD +112",        1'b0, 8'd112);
    step_and_check("ADD +32",         1'b0, 8'd32);

    // Cụm 3
    $display("\n=== KIỂM TRA PHÉP TRỪ ===");
    do_reset_and_prime("SUB cơ bản");
    step_and_check("PREP +50",        1'b0, 8'd50);
    step_and_check("SUB  -20",        1'b1, 8'd20);
    step_and_check("SUB  -40",        1'b1, 8'd40);

    // Cụm 4
    $display("\n=== KIỂM TRA OVERFLOW KHI TRỪ ===");
    do_reset_and_prime("OVF SUB");
    step_and_check("LOAD -128",       1'b0, 8'h80);
    step_and_check("MIN-1 (OVF)",     1'b1, 8'h01);

    // Cụm 5
    $display("\n=== KIỂM TRA MAX_VALUE + 1 ===");
    do_reset_and_prime("MAX+1");
    step_and_check("LOAD +127",       1'b0, 8'h7F);
    step_and_check("+1 (OVF)",        1'b0, 8'h01);

    // Cụm 6
    $display("\n=== KIỂM TRA MIN_VALUE + MAX_VALUE ===");
    do_reset_and_prime("MIN+MAX");
    step_and_check("LOAD -128",       1'b0, 8'h80);
    step_and_check("ADD +127",        1'b0, 8'h7F);
    step_and_check("ADD +1",          1'b0, 8'h01);

    // Cụm 7
    $display("\n=== KIỂM TRA RESET TRONG KHI CHẠY ===");
    step_and_check("RUN +0x55",       1'b0, 8'h55);
    do_reset_and_prime("Reset tức thời");
    step_and_check("RUN +0x33",       1'b0, 8'h33);

    // Cụm 8 (C=V=1)
    $display("\n=== EXTRA: TỔ HỢP CỜ (C=V=1) ===");
    do_reset_and_prime("ADD C=V=1");
    step_and_check("ADD 0x80",              1'b0, 8'h80);
    step_and_check("ADD 0x80 → C=V=1",      1'b0, 8'h80);
    step_and_check("NOP",                   1'b0, 8'h00);

    do_reset_and_prime("SUB C=V=1");
    step_and_check("LOAD 0x80",             1'b0, 8'h80);
    step_and_check("SUB  0x01 → C=V=1",     1'b1, 8'h01);
    step_and_check("NOP",                   1'b0, 8'h00);

    $display("\n=== TB finished ===");
    #10 $finish;
  end

  // ===== Waveform =====
  initial begin
    $dumpfile("ex2_results.vcd");
    $dumpvars(0, ex2_tb);
    $dumpvars(0, ex2_tb.carry_wide, ex2_tb.overflow_wide);
  end
endmodule
