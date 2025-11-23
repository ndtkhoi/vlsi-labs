// 00_src/ex1_nor2.sv  // RTL cell (EX1)
module nor2(
input  logic A,B, 
output logic Y
); 
assign Y = ~(A | B); 
endmodule
