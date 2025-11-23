// ================== Common: ripple-carry adder ==================
// Module alu_registered - by NGUYEN DINH TRONG KHOI
// Purpose: Auto description placeholder for alu_registered
module alu_registered #(parameter int N=8)(
  input  logic [N-1:0] a, b,
  input  logic         cin,
  output logic [N-1:0] sum,
  output logic         cout
);
  logic [N:0] c; assign c[0]=cin;
  genvar i;
  generate
    for (i=0;i<N;i++) begin : G
      wire axb = a[i]^b[i];
      assign sum[i] = axb ^ c[i];
      assign c[i+1] = (a[i]&b[i])|(a[i]&c[i])|(b[i]&c[i]);
    end
  endgenerate
  assign cout = c[N];
endmodule
// ================== ALU khớp SEL ==================
// SEL:
//   00: Y = S + A
//   01: Y = S - A
//   10: Y = max(S, A)  (signed)
//   11: Y = min(S, A)  (signed)
module alu8 #(parameter int N=8)(
  input  logic [N-1:0] S_in,
  input  logic [N-1:0] A_in,
  input  logic [1:0]   Sel,
  output logic [N-1:0] Y,
  output logic         C_raw,   // carry / ~borrow cho ADD/SUB, còn lại 0
  output logic         V_raw    // overflow 2’s comp cho ADD/SUB, còn lại 0
);
  //cộng/trừ ( ALU của sơ đồ)
  logic [N-1:0] add_sum, sub_sum;
  logic add_co, sub_co;
  rc_adder #(.N(N)) u_add (.a(S_in), .b(A_in),  .cin(1'b0), .sum(add_sum), .cout(add_co));
  rc_adder #(.N(N)) u_sub (.a(S_in), .b(~A_in), .cin(1'b1), .sum(sub_sum), .cout(sub_co)); // ~borrow

  // so sánh có dấu cho max/min (Logic circuit trong sơ đồ)
  wire signed [N-1:0] Ss = S_in;
  wire signed [N-1:0] As = A_in;
  wire [N-1:0] max_s = (Ss < As) ? A_in : S_in;
  wire [N-1:0] min_s = (Ss < As) ? S_in : A_in;

  // overflow theo quy tắc dấu
  wire Sa = S_in[N-1], Aa = A_in[N-1];

  always_comb begin
    unique case (Sel)
      2'b00: begin // ADD
        Y     = add_sum;
        C_raw = add_co;
        V_raw = (~(Sa ^ Aa)) & (Sa ^ add_sum[N-1]);
      end
      2'b01: begin // SUB
        Y     = sub_sum;
        C_raw = sub_co;                 // ~borrow
        V_raw =  (Sa ^ Aa)  & (Sa ^ sub_sum[N-1]);
      end
      2'b10: begin // MAX (signed)
        Y     = max_s;
        C_raw = 1'b0;
        V_raw = 1'b0;
      end
      default: begin // 2'b11: MIN (signed)
        Y     = min_s;
        C_raw = 1'b0;
        V_raw = 1'b0;
      end
    endcase
  end
endmodule

// ================== TOP ==================
module ex4 #(parameter int N=8)(
  input  logic         clk,
  input  logic         rst_n,
  input  logic [N-1:0] A,
  input  logic [1:0]   Sel,
  output logic [N-1:0] S,        // thanh ghi trạng thái/ra
  output logic         carry,    // 2 FF cờ riêng
  output logic         overflow
);
  // FF đầu vào & trạng thái 
  logic [N-1:0] A_q, S_q;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      A_q <= '0;
      S_q <= '0;
    end else begin
      A_q <= A;      // chốt A
      S_q <= S;      // feedback S hiện tại vào ALU ở chu kỳ kế
    end
  end

  // ALU 
  logic [N-1:0] Y_next;
  logic C_next, V_next;
  alu8 #(.N(N)) u_alu (
    .S_in (S_q),
    .A_in (A_q),
    .Sel  (Sel),
    .Y    (Y_next),
    .C_raw(C_next),
    .V_raw(V_next)
  );

  // FF đầu ra (S, carry, overflow) – ba DFF 
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      S        <= '0;
      carry    <= 1'b0;
      overflow <= 1'b0;
    end else begin
      S        <= Y_next;
      carry    <= C_next;
      overflow <= V_next;
    end
  end
endmodule
