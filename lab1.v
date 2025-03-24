
module studio1(
    output [9:0] led,
    input [9:0] sw,
    output [3:0] an,
    output[6:0] seg,
    output dp
    );
    assign dp = 1'b1;
    assign led = sw;
    
    wire correct_password = (sw == 10'b0000011001);
    wire [6:0] x_char = 7'b0001001; // turn off A and D
    assign an = correct_password? 4'b0011:4'b0000; // 0 is to on, 1 is to off
    assign seg = x_char;
    
endmodule

