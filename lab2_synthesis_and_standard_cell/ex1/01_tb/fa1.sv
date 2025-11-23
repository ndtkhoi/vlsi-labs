//==========================================
// Full Adder 1-bit
// SUM  = A ^ B ^ CIN
// COUT = AB + ACIN + BCIN
//==========================================
module fa1 (
    input  logic A,
    input  logic B,
    input  logic CIN,
    output logic SUM,
    output logic COUT
);
    always_comb begin
        SUM  = A ^ B ^ CIN;
        COUT = (A & B) | (A & CIN) | (B & CIN);
    end
endmodule
