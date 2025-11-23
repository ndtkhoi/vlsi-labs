
`timescale 1ns/1ps

// Module alu_registered_tb - by NGUYEN DINH TRONG KHOI
// Purpose: Auto description placeholder for alu_registered_tb
module alu_registered_tb;
  localparam int N = 8;

  // Clock & reset
  logic clk = 0, rst_n;
  always #5 clk = ~clk; // 100 MHz

  // DUT I/O
  logic [N-1:0] A;
  logic  [1:0]  Sel;
  logic [N-1:0] S;
  logic         carry, overflow;

  // DUT
  ex4 dut (.clk(clk), .rst_n(rst_n), .A(A), .Sel(Sel), .S(S), .carry(carry), .overflow(overflow));

  // ---------- GOLDEN MODEL ----------
  typedef logic signed [N-1:0] sbyte;

  // Trạng thái model (ứng với S sau mỗi vector hoàn tất)
  sbyte S_state;

  // Hàm overflow 2's-complement từ quy tắc dấu (đồng nhất với RTL)
  function automatic logic ov_add (sbyte a, sbyte b, sbyte r);
    return (~(a[N-1] ^ b[N-1])) & (a[N-1] ^ r[N-1]);
  endfunction
  function automatic logic ov_sub (sbyte a, sbyte b, sbyte r);
    return (a[N-1] ^ b[N-1]) & (a[N-1] ^ r[N-1]);
  endfunction

  function automatic sbyte add_ref (sbyte x, sbyte y, output logic c_out);
    logic [N:0] u;
    u     = {1'b0,x} + {1'b0,y};   // TB dùng + được
    c_out = u[N];
    return u[N-1:0];
  endfunction

  function automatic sbyte sub_ref (sbyte x, sbyte y, output logic c_out); // c_out = ~borrow
    logic [N:0] u;
    u     = {1'b0,x} + {1'b0,~y} + 1;
    c_out = u[N];
    return u[N-1:0];
  endfunction

  integer err_cnt = 0;

  // Một vector chuẩn pipeline (KHÔNG thêm chu kỳ thừa):
  //   - T0: set A/Sel
  //   - T1: (posedge) DUT chốt A_q/S_q
  //   - T2: (posedge) DUT ra kết quả -> so sánh với ref = f(S_state, A, Sel)
  task automatic drive_and_check(input logic [1:0] sel, input byte aval);
    sbyte r; logic c,v;

    // Tính trước expected từ trạng thái hiện tại (S_state) và A vừa apply
    unique case (sel)
      2'b00: begin
        r = add_ref(S_state, sbyte'(aval), c);
        v = ov_add(S_state, sbyte'(aval), r);
      end
      2'b01: begin
        r = sub_ref(S_state, sbyte'(aval), c);
        v = ov_sub(S_state, sbyte'(aval), r);
      end
      2'b10: begin
        r = (S_state < sbyte'(aval)) ? sbyte'(aval) : S_state;
        c = 1'b0; v = 1'b0;
      end
      default: begin
        r = (S_state < sbyte'(aval)) ? S_state : sbyte'(aval);
        c = 1'b0; v = 1'b0;
      end
    endcase

    // T0: áp vector
    Sel = sel; A = aval;

    // T1: chốt A_q/S_q
    @(posedge clk);

    // T2: kết quả xuất hiện -> so sánh
    @(posedge clk); #1step;
    if (S !== r)          begin $error("S exp=%0d got=%0d sel=%b A=%0d", $signed(r), $signed(S), sel, $signed(aval)); err_cnt++; end
    if (carry !== c)      begin $error("C exp=%0b got=%0b sel=%b", c, carry, sel); err_cnt++; end
    if (overflow !== v)   begin $error("V exp=%0b got=%0b sel=%b", v, overflow, sel); err_cnt++; end

    // Cập nhật trạng thái model cho vector kế tiếp
    S_state = r;
  endtask

  // Test sequence
  initial begin
    $display("** ex4_tb start (Cach 2 – pipeline-correct, no extra hold) **");

    // Reset
    rst_n = 0;
    A = '0; Sel = 2'b00;
    S_state = '0;
    repeat (2) @(posedge clk);
    rst_n = 1;

    // ---- Directed corners ----
    drive_and_check(2'b00, 8'sd127);  // +127  -> 127
    drive_and_check(2'b00, 8'sd1);    // +1    -> -128,  V=1
    drive_and_check(2'b01, -128);     // -(-128) -> 0,   V=0
    drive_and_check(2'b01, -1);       // -(-1)   -> +1,  V=0

    // seed rồi max/min
    drive_and_check(2'b00, 8'sd5);    // add 5
    drive_and_check(2'b10, 8'sd10);   // max
    drive_and_check(2'b11, -20);      // min
    drive_and_check(2'b10, -5);       // max
    drive_and_check(2'b11, 0);        // min

    // ---- Random smoke ----
    for (int k=0; k<40; k++)
      drive_and_check($urandom_range(0,3), $urandom_range(0,255));

    $display("Errors = %0d", err_cnt);
    if (err_cnt==0) $display("** ex4_tb: ALL TESTS PASSED **");
    else            $fatal(1, "** ex4_tb: FAILED with %0d errors **", err_cnt);
    $finish;
  end
endmodule
