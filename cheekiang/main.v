`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2024 11:02:31
// Design Name: 
// Module Name: specification_board
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


module specification_board(input clock, input [15:0]sw,
                           input btnC, input btnU, input btnL, input btnR, input btnD,
                           output [15:0]led, output reg [7:0]seg, output reg [3:0]an);
    wire [7:0]seg_a;
    wire [7:0]seg_c;
    wire [3:0]an_a;
    wire [3:0]an_c; 
    
    wire completed_;

    wire clk_1hz;
    wire clk_2hz;
    wire clk_10hz;
    wire clk_1khz;
    
    frequency1 f1(clock, clk_1hz);
    frequency2 f2(clock, clk_2hz);
    frequency10 f10(clock, clk_10hz);
    frequency1k f1k(clock, clk_1khz);
    
    // Pass in 1kHz clock for easy counting. 
    // count = 1000 => Period = 1seconds. Scale from here
     
    //subtaskA
    subtaska TASKA(sw[0], sw[15], btnL, btnR, seg_a, an_a);
    //subtaskB
    subtaskb TASKB(clk_1khz, sw[13], sw[2], led[14:10], led[8:2], completed_);
    
    //subtaskC
    subtaskc TASKC(clk_2hz, clk_1khz, btnD, 
                   led[0], led[1], led[15],seg_c, an_c);
    
    always @(posedge clock) begin
      seg = completed_ ? seg_c: seg_a;
       an = completed_ ? an_c: an_a;
   end

                   
endmodule
