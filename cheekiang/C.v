`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2024 14:58:14
// Design Name: 
// Module Name: subtaskc
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


module subtaskc(input clock_2hz, input clock_1khz, input btnD,
                output led0,output led1, output led15,
                output reg [7:0]seg, output reg[3:0]an
    );
    assign led0 = btnD ? clock_2hz : 0;
    assign led1 = btnD ? clock_2hz : 0;
    assign led15 = btnD ? clock_2hz : 0;
    
    reg [31:0] count = 0;
    reg [2:0]stage = 0;
    
    always @(posedge clock_1khz)begin
        count = (count == 800) ? 0 : count + 1;
        stage = (count == 0) ? stage + 1: stage;
        
        if (stage == 0) begin
            an = 4'b0111;
            seg = 8'b1000_0011;
        end
        if (stage == 1) begin
            an = 4'b1011;
            seg = 8'b1010_0011;
        end
        if (stage == 2) begin
            an = 4'b1101;
            seg = 8'b1000_0111;
        end
        if (stage == 3) begin
            an = 4'b1110;
            seg = 8'b1000_1011;
        end
        if (stage == 4) begin
            an = 4'b0111;
            seg = 8'b0001_0000;
        end
        if (stage == 5) begin
            an = 4'b1011;
            seg = 8'b0000_1000;
        end        
        if (stage == 6) begin
            an = 4'b1101;
            seg = 8'b0000_0111;
        end
        if (stage == 7) begin
            an = 4'b1110;
            seg = 8'b0000_0110;
        end

    end
        
endmodule
