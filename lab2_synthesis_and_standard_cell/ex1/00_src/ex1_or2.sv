// 00_src/ex1_or2.sv  // RTL cell (EX1)
module or2(
input  logic A,B, 
output logic Y
); 
assign Y = A | B; 
endmodule
