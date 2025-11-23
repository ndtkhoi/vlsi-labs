module ex4 (          //counter
input  logic clk,
input  logic rst,
output logic [1:0] Q
);
 always_ff @(posedge clk) begin
  if (rst) Q <= 2'b00;
  else     Q <= Q + 2'b01;
 end
endmodule