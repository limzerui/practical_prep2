module top_module(
    input clk,           
    output [7:0] seg,   
    output [3:0] an     
);

    reg [6:0] number;   
    
    initial begin
        number = 100;     
    end

    seven_seg_controller ssc (
        .clk(clk),
        .number(number),
        .seg(seg),
        .an(an)
    );

endmodule

module seven_seg_controller(
    input clk,            
    input [6:0] number,   
    output reg [7:0] seg, 
    output reg [3:0] an   
);

  wire animation_clk;
  clk_divider cd(
        clk,
        animation_clk);   

  reg [1:0] digit;       
  reg [3:0] digit_value [3:0]; 

  always @(*) begin
    digit_value[0] = number / 100;          
    digit_value[1] = (number % 100) / 10;  
    digit_value[2] = number % 10;          
    digit_value[3] = 0;                    
  end

  always @(posedge animation_clk) begin
    digit <= digit + 1;
  end

  always @(*) begin
    case(digit)
      2'b00: begin
        an  = 4'b0111;   
        seg = seven_seg_display(digit_value[0]);
      end
      2'b01: begin
        an  = 4'b1011;   
        seg = seven_seg_display(digit_value[1]);
      end
      2'b10: begin
        an  = 4'b1101;   
        seg = seven_seg_display(digit_value[2]);
      end
      2'b11: begin
        an  = 4'b1110;   
        seg = 8'b11111111; 
      end
      default: begin
        an  = 4'b1111;   
        seg = 8'b11111111; 
      end
    endcase
  end

  function [7:0] seven_seg_display;
    input [3:0] digit; 
    begin
      case(digit)
        4'b0000: seven_seg_display = 8'b11000000; 
        4'b0001: seven_seg_display = 8'b11111001; 
        4'b0010: seven_seg_display = 8'b11111001; 
        4'b0011: seven_seg_display = 8'b10110000; 
        4'b0100: seven_seg_display = 8'b10011001; 
        4'b0101: seven_seg_display = 8'b10010010; 
        4'b0110: seven_seg_display = 8'b10000010; 
        4'b0111: seven_seg_display = 8'b11111000; 
        4'b1000: seven_seg_display = 8'b10000000; 
        4'b1001: seven_seg_display = 8'b10010000; 
        default: seven_seg_display = 8'b11111111; 
      endcase
    end
  endfunction

endmodule

module clk_divider(
    input CLOCK,
    output reg SLOW_CLOCK3
    );

    reg [18:0] COUNT3;

    initial begin
        SLOW_CLOCK3 = 0;
        COUNT3 = 0;
    end

    always @ (posedge CLOCK) begin
        if (COUNT3 == 149999 ) begin
            SLOW_CLOCK3 <= ~SLOW_CLOCK3;
            COUNT3 <= 0;
            end
        else begin
            COUNT3 <= COUNT3 + 1;
            end
     end
       
endmodule
