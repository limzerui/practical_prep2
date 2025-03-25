`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2024 14:40:46
// Design Name: 
// Module Name: subtaska
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module subtaska(input sw0, input sw15, input btnL, input btnR,
                output reg [7:0] seg = 8'b11010100, 
                output reg [3:0]an = 4'b1111
    );
    always @(*) begin
    if (sw0 == 1 && btnR == 1) begin
        an[1] <= 0;
    end else begin
        an[1] <= 1;
    end 
    
    if (sw15 == 1 && btnL == 1) begin
        an[2] <= 0; 
    end else begin
        an[2] <= 1;
    end
    end
    
endmodule
