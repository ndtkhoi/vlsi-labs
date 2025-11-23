// Module accumulator8bit - by NGUYEN DINH TRONG KHOI
// Purpose: Auto description placeholder for accumulator8bit
module accumulator8bit(input logic a,b,cin, output logic s,cout);
  logic p; assign p=a^b; assign s=p^cin;
  assign cout = (a&b)|(a&cin)|(b&cin);
endmodule
module rca #(parameter N=8)(
  input  logic [N-1:0] A,B,
  input  logic         cin,
  output logic [N-1:0] S,
  output logic         cout,
  output logic         c_msb_in_xor_out
);
  logic [N:0] C; assign C[0]=cin;
  genvar i; generate
    for (i=0;i<N;i++) begin: G
      fa1 u(.a(A[i]),.b(B[i]),.cin(C[i]),.s(S[i]),.cout(C[i+1]));
    end
  endgenerate
  assign cout = C[N];
  assign c_msb_in_xor_out = C[N-1]^C[N]; // ovf 2's comp
endmodule
module ex1(                     // ===== EXPERIMENT 1 ===
  input  logic       clk,       
  input  logic       rst_n,     // 
  input  logic [7:0] A,         // vào thanh ghi A (R/Q)
  output logic [7:0] S,         // ra từ thanh ghi S (R/Q)
  output logic       overflow,  // qua DFF
  output logic       carry      // qua DFF
);
  logic [7:0] A_q;        // Thanh ghi A (R/Q ở góc trên)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) A_q <= 8'b0;
    else        A_q <= A;
  end
  logic [7:0] S_q, S_next; // Thanh ghi S + vòng hồi tiếp
  logic C_out, V_raw, V_dff, C_dff;
  rca #(8) u_add(
    .A(S_q), .B(A_q), .cin(1'b0),
    .S(S_next), .cout(C_out), .c_msb_in_xor_out(V_raw)
  );
  wire logic_carry    = C_out; //tạo tín hiệu cờ
  wire logic_overflow = V_raw;
  always_ff @(posedge clk or negedge rst_n) begin // 2 DFF cho carry & overflow
    if (!rst_n) begin
      C_dff <= 1'b0;
      V_dff <= 1'b0;
    end else begin
      C_dff <= logic_carry;
      V_dff <= logic_overflow;
    end
  end
  always_ff @(posedge clk or negedge rst_n) begin  // --- Thanh ghi kết quả S
    if (!rst_n) S_q <= 8'b0;
    else        S_q <= S_next;
  end
  assign S        = S_q;  // xuất S
  assign carry    = C_dff;
  assign overflow = V_dff;
endmodule
