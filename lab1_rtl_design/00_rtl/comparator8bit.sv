// Module comparator8bit - by NGUYEN DINH TRONG KHOI
// Purpose: Auto description placeholder for comparator8bit
module comparator8bit(
  input  logic       sel,    // 1 => X, 0 => Y
  input  logic [7:0] X,
  input  logic [7:0] Y,
  output logic [7:0] Z
);
  assign Z = sel ? X : Y;
endmodule
// ===== 8-bit signed comparator
module magcomp8_signed(
  input  logic [7:0] A,
  input  logic [7:0] B,
  output logic       AgtB,
  output logic       AeqB,
  output logic       AltB
);
  integer i;
  logic decided;
  always_comb begin
    AgtB    = 1'b0;
    AltB    = 1'b0;
    AeqB    = 1'b0;
    decided = 1'b0;
    // Quét từ MSB -> LSB, chọn bit khác nhau đầu tiên để quyết định
    for (i = 7; i >= 0; i--) begin
      if (!decided && (A[i] ^ B[i])) begin
        if (i == 7) begin
          // khác dấu: bit dấu quyết định (1 => âm < dương)
          AgtB = (~A[7] &  B[7]);  // A dương, B âm -> A > B
          AltB = ( A[7] & ~B[7]);  // A âm,   B dương -> A < B
        end else begin
          // cùng dấu: so sánh bình thường ở bit khác nhau đầu tiên
          AgtB = ( A[i] & ~B[i]);
          AltB = (~A[i] &  B[i]);
        end
        decided = 1'b1;
      end
    end
    // Nếu không có bit nào khác nhau -> bằng nhau
    if (!decided) begin
      AeqB = 1'b1;
      AgtB = 1'b0;
      AltB = 1'b0;
    end
  end
endmodule
// ===== Top =======
module ex3(
  input  logic [7:0] A,
  input  logic [7:0] B,
  output logic [7:0] Min,
  output logic [7:0] Max
);
  logic AgtB, AeqB, AltB;
  // Bộ so sánh có dấu
  magcomp8_signed u_cmp(.A(A), .B(B), .AgtB(AgtB), .AeqB(AeqB), .AltB(AltB));
  // Hai mux 2:1: Min = (A<B)?A:B ; Max = (A>B)?A:B
  mux2_8 u_min(.sel(AltB), .X(A), .Y(B), .Z(Min));
  mux2_8 u_max(.sel(AgtB), .X(A), .Y(B), .Z(Max));
endmodule
