// 00_src/ex1_not.sv  // RTL cell (EX1)
module not1(
input  logic A, 
output logic Y
); 
assign Y = ~A; 
endmodule
