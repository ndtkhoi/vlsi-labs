// 00_src/ex1_nand2.sv  // RTL cell (EX1)
module nand2(
input logic A,B, 
output logic Y
); 
assign Y = ~(A & B); 
endmodule
