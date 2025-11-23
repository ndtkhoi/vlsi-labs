`timescale 1ns/1ps  
// Module accumulator8bit_tb - by NGUYEN DINH TRONG KHOI
// Purpose: Auto description placeholder for accumulator8bit_tb
module accumulator8bit_tb;
    logic        clk;
    logic        rst_n;
    logic [7:0]  A;
    logic [7:0]  S;
    logic        carry;
    logic        overflow;
    // Kết nối DUT 
    ex1 dut(
        .clk(clk),
        .rst_n(rst_n),
        .A(A),
        .S(S),
        .carry(carry),
        .overflow(overflow)
    );
    // Clock 10ns
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        rst_n = 0;
        A = 8'h00;
        repeat(2) @(posedge clk);
        rst_n = 1;

        A = 8'h05;
        repeat(3) @(posedge clk);
        A = 8'hFF;
        @(posedge clk);
        A = 8'h7F;
        @(posedge clk);
        A = 8'h80;
        @(posedge clk);
        repeat(5) @(posedge clk);

        rst_n = 0;
        @(posedge clk);
        rst_n = 1;

        A = 8'h03;
        repeat(3) @(posedge clk);
        #10 $finish;
    end

    initial begin
        $display("Thời gian\t A\t S\t carry\t overflow");
        $monitor("%t\t %h\t %h\t %b\t %b", $time, A, S, carry, overflow);
    end

    initial begin
        $dumpfile("ex1.vcd");
        $dumpvars(0, ex1_tb);
    end
endmodule
