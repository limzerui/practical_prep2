`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2024 14:46:10
// Design Name: 
// Module Name: subtaskb
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


module subtaskb(input clock, input sw13, input sw2, 
                output reg [4:0]ledL = 0, output reg [6:0]ledR = 0, output reg completed = 0);
    reg [31:0] countL = 0;
    reg [31:0] countR = 0;
    reg [31:0] tresholdL = 1300;
    reg [31:0] tresholdR = 2600;
    
    reg [31:0] stageL = 0;
    reg [31:0] stageR = 0;
    reg completedL = 0;
    reg completedR = 0;
     
    always @(posedge clock) begin
        if (sw13) begin
            countL = (countL == tresholdL) ? 0 : countL + 1;
            stageL = (countL == 0 & stageL != 5) ? stageL + 1 : stageL;
            if (stageL >= 1) begin 
                ledL[4] <= 1; 
                completedL <= 1;
            end
            if (stageL >= 2) begin ledL[3] <= 1; end
            if (stageL >= 3) begin ledL[2] <= 1; end
            if (stageL >= 4) begin ledL[1] <= 1; end
            if (stageL >= 5) begin ledL[0] <= 1; end        
        end      

        if (sw2) begin
            countR = (countR == tresholdR) ? 0 : countR + 1;
            stageR = (countR == 0 & stageR != 7) ? stageR + 1 : stageR;
            if (stageR >= 1) begin 
                ledR[0] <= 1; 
                completedR <= 1;
            end
                
            if (stageR >= 2) begin ledR[1] <= 1; end
            if (stageR >= 3) begin ledR[2] <= 1; end
            if (stageR >= 4) begin ledR[3] <= 1; end
            if (stageR >= 5) begin ledR[4] <= 1; end        
            if (stageR >= 6) begin ledR[5] <= 1; end
            if (stageR >= 7) begin ledR[6] <= 1; end
        end  
        
        completed = (completedL == 1 && completedR == 1) ? 1 : 0;     
    end        
endmodule
