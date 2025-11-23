// Module accumulator8bit_addsub - by NGUYEN DINH TRONG KHOI
// Purpose: Auto description placeholder for accumulator8bit_addsub
module accumulator8bit_addsub(input logic a,b,cin, output logic s,cout);
  logic p; 
  assign p    = a ^ b;
  assign s    = p ^ cin;
  assign cout = (a & b) | (a & cin) | (b & cin);
endmodule
// RCA
module rca #(parameter N=8)(
  input  logic [N-1:0] A, B,
  input  logic         cin,
  output logic [N-1:0] S,
  output logic         cout,
  output logic         c_msb_in_xor_out 
);
  logic [N:0] C; 
  assign C[0] = cin;

  genvar i;
  generate
    for (i=0;i<N;i++) begin : G
      fa1 u(.a(A[i]), .b(B[i]), .cin(C[i]), .s(S[i]), .cout(C[i+1]));
    end
  endgenerate

  assign cout             = C[N];
  assign c_msb_in_xor_out = C[N-1] ^ C[N];
endmodule
// ===== EXPERIMENT 2: Add/Sub Accumulator =====
// add_sub=0 -> S := S + A
// add_sub=1 -> S := S - A 
module ex2(
  input  logic       clk,
  input  logic       rst_n,    
  input  logic       add_sub,   // 0: add, 1: subtract
  input  logic [7:0] A,
  output logic [7:0] S,
  output logic       carry,     
  output logic       overflow   
);
  // --- Input reg ---
  logic [7:0] A_q;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      A_q       <= 8'b0;
    end else begin
      A_q       <= A;
    end
  end

  // --- Accumulator reg ---
  logic [7:0] S_q;
  // adder_result is computed combinationally below and then registered into S_q
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) S_q <= 8'b0;
    else        S_q <= adder_result;

  logic [7:0] adder_result;
  logic       C_out, V_raw;

  // IMPORTANT: use continuous assigns so Bx/cin always track A_q/add_sub_q
  logic [7:0] Bx;
  logic       cin;
  assign Bx  = A_q ^ {8{add_sub}}; // subtract -> ~A_q, add -> A_q
  assign cin = add_sub;

  rca #(8) u_add(
    .A(S_q), .B(Bx), .cin(cin),
    .S(adder_result), .cout(C_out), .c_msb_in_xor_out(V_raw)
  );
    // --- Flag reg  --
  logic C_dff, V_dff;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      C_dff <= 1'b0;
      V_dff <= 1'b0;
    end else begin
      C_dff <= C_out;  // carry out of the adder 
      V_dff <= V_raw;  // two’s complement ovf
    end
  end
  // --- Out -----
  assign S        = S_q;
  assign carry    = C_dff;
  assign overflow = V_dff;
endmodule