`timescale 1ns/1ps

// Module comparator8bit_tb - by NGUYEN DINH TRONG KHOI
// Purpose: Auto description placeholder for comparator8bit_tb
module comparator8bit_tb;
    // Tín hiệu kiểm tra
    logic [7:0] A;
    logic [7:0] B;
    logic [7:0] Min;
    logic [7:0] Max;
    
    // Khởi tạo module cần kiểm tra
    ex3 dut(
        .A(A),
        .B(B),
        .Min(Min),
        .Max(Max)
    );
    
    // Hàm hiển thị kết quả
    function void display_result;
        $display("A = %d (0x%h), B = %d (0x%h) => Min = %d (0x%h), Max = %d (0x%h)", 
                 $signed(A), A, $signed(B), B, $signed(Min), Min, $signed(Max), Max);
    endfunction
    
    // Kịch bản kiểm tra
    initial begin
        $display("===== KIỂM TRA MẠCH TÌM MIN-MAX =====");
        
        // Trường hợp 1: A > B
        A = 8'd100;
        B = 8'd50;
        #10;
        display_result();
        assert(Min == B && Max == A) else $error("Test case 1 failed!");
        
        // Trường hợp 2: A < B
        A = 8'd25;
        B = 8'd75;
        #10;
        display_result();
        assert(Min == A && Max == B) else $error("Test case 2 failed!");
        
        // Trường hợp 3: A = B
        A = 8'd42;
        B = 8'd42;
        #10;
        display_result();
        assert(Min == A && Max == B) else $error("Test case 3 failed!");
        
        // Trường hợp 4: A và B là số âm, A < B
        A = 8'b10001000; // -120
        B = 8'b10001111; // -113
        #10;
        display_result();
        assert(Min == A && Max == B) else $error("Test case 4 failed!"); // Sửa A là Min, B là Max
        
        // Trường hợp 5: A và B là số âm, A > B
        A = 8'b11110000; // -16
        B = 8'b10100000; // -96
        #10;
        display_result();
        assert(Min == B && Max == A) else $error("Test case 5 failed!");
        
        // Trường hợp 6: A âm, B dương
        A = 8'b10000001; // -127
        B = 8'b01111111; // 127
        #10;
        display_result();
        assert(Min == A && Max == B) else $error("Test case 6 failed!"); // Sửa A là Min, B là Max
        
        // Trường hợp 7: A dương, B âm
        A = 8'b01111111; // 127
        B = 8'b10000000; // -128
        #10;
        display_result();
        assert(Min == B && Max == A) else $error("Test case 7 failed!"); // Sửa B là Min, A là Max
        
        // Trường hợp 8: Giá trị biên - Min, Max của biểu diễn bù 2
        A = 8'b01111111; // 127 (MAX_VALUE)
        B = 8'b10000000; // -128 (MIN_VALUE)
        #10;
        display_result();
        assert(Min == B && Max == A) else $error("Test case 8 failed!"); // Sửa B là Min, A là Max
        
        // Trường hợp 9: Kiểm tra bit-by-bit từ MSB
        A = 8'b01010101;
        B = 8'b01100000;
        #10;
        display_result();
        assert(Min == A && Max == B) else $error("Test case 9 failed!");
        
        // Trường hợp 10: Kiểm tra với các bit thay đổi chỉ ở LSB
        A = 8'b00001010;
        B = 8'b00001001;
        #10;
        display_result();
        assert(Min == B && Max == A) else $error("Test case 10 failed!");
        
        $display("===== KẾT THÚC KIỂM TRA =====");
        $finish;
    end
    
    // Tạo file waveform
    initial begin
        $dumpfile("ex3_waveform.vcd");
        $dumpvars(0, ex3_tb);
    end
endmodule