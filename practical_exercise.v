module top(
    input clk,              // 100MHz system clock
    input btnR,             // Right button input
    input btnC,             // Center button input
    output reg [3:0] an,    // 4 anode control signals for 7-segment displays
    output reg [7:0] seg,   // 8 cathode control signals for 7-segment displays
    input [15:0] sw,        // 16 switches
    output reg [15:0] led   // 16 individual LEDs
    );

    // 7-segment display patterns for various characters and digits
    parameter   SEG_L = 8'b11001111,  // Letter L
                SEG_C = 8'b10100111,  // Letter C
                SEG_R = 8'b10101111,  // Letter R
                SEG_D = 8'b10100001,  // Letter D
                SEG_U = 8'b11100011,  // Letter U
                SEG_0 = 8'b11000000,  // Digit 0
                SEG_1 = 8'b11111001,  // Digit 1
                SEG_2 = 8'b10100100,  // Digit 2
                SEG_3 = 8'b10110000,  // Digit 3
                SEG_4 = 8'b10011001,  // Digit 4
                SEG_5 = 8'b10010010,  // Digit 5
                SEG_6 = 8'b10000010,  // Digit 6
                SEG_7 = 8'b11111000,  // Digit 7
                SEG_8 = 8'b10000000,  // Digit 8
                SEG_9 = 8'b10010000,  // Digit 9
                SEG_A = 8'b10001000,  // Digit A (for 10)
                SEG_b = 8'b10000011,  // Digit b (for 11)
                SEG_C2 = 8'b10100111, // Digit C (for 12)
                SEG_d = 8'b10100001,  // Digit d (for 13)
                SEG_E = 8'b10000110,  // Digit E (for 14)
                SEG_F = 8'b10001110,  // Digit F (for 15)
                // Anode control patterns (active low)
                AN_1 = 4'b1110,       // Rightmost display active
                AN_2 = 4'b1101,       // Second from right active
                AN_3 = 4'b1011,       // Second from left active
                AN_4 = 4'b0111;       // Leftmost display active
                
    // Define exclude bits - these are the switches that will trigger display
    // Using 6 exclude switches for example (could be modified as needed)
    wire [5:0] ex;
    assign ex = sw[5:0];  // First 6 switches are the exclude switches
    
    // Variables for display control
    reg [3:0] digit_to_display;  // Which digit to show (0-15)
    reg display_active;          // Whether to show a digit
    
    // Initialize all outputs
    initial begin
        // Turn off all 7-segment displays
        an = 4'b1111;
        seg = 8'b11111111;
        
        // Set LEDs 12 through 2 on, except for LED 8
        led = 16'b0001_1111_0111_1100;
        
        // Initially no switch is active
        digit_to_display = 4'h0;
        display_active = 0;
    end
    
    // Detect exclude switch activations
    always @(posedge clk) begin
        display_active = 0;  // Default to no display
        digit_to_display = 4'h0;
        
        // Check each exclude switch
        if (sw[0]) begin
            digit_to_display = 4'h0;
            display_active = 1;
        end
        else if (sw[1]) begin
            digit_to_display = 4'h1;
            display_active = 1;
        end
        else if (sw[2]) begin
            digit_to_display = 4'h2;
            display_active = 1;
        end
        else if (sw[3]) begin
            digit_to_display = 4'h3;
            display_active = 1;
        end
        else if (sw[4]) begin
            digit_to_display = 4'h4;
            display_active = 1;
        end
        else if (sw[5]) begin
            digit_to_display = 4'h5;
            display_active = 1;
        end
        else if (sw[6]) begin
            digit_to_display = 4'h6;
            display_active = 1;
        end
        else if (sw[7]) begin
            digit_to_display = 4'h7;
            display_active = 1;
        end
        else if (sw[8]) begin
            digit_to_display = 4'h8;
            display_active = 1;
        end
        else if (sw[9]) begin
            digit_to_display = 4'h9;
            display_active = 1;
        end
        else if (sw[10]) begin
            digit_to_display = 4'hA;
            display_active = 1;
        end
        else if (sw[11]) begin
            digit_to_display = 4'hB;
            display_active = 1;
        end
        else if (sw[12]) begin
            digit_to_display = 4'hC;
            display_active = 1;
        end
        else if (sw[13]) begin
            digit_to_display = 4'hD;
            display_active = 1;
        end
        else if (sw[14]) begin
            digit_to_display = 4'hE;
            display_active = 1;
        end
        else if (sw[15]) begin
            digit_to_display = 4'hF;
            display_active = 1;
        end
        
        // Keep LEDs 12 through 2 on, except for LED 8
        led <= 16'b0001_1101_1111_1100;
    end
    
    // Control the 7-segment display
    always @(posedge clk) begin
        if (display_active) begin
            // Enable rightmost display
            an <= AN_1&AN_2&AN_4;
            
            // Display the appropriate digit based on which exclude switch is on
            case (digit_to_display)
                4'h0: seg <= SEG_0;
                4'h1: seg <= SEG_1;
                4'h2: seg <= SEG_2;
                4'h3: seg <= SEG_3;
                4'h4: seg <= SEG_4;
                4'h5: seg <= SEG_5;
                4'h6: seg <= SEG_6;
                4'h7: seg <= SEG_7;
                4'h8: seg <= SEG_8;
                4'h9: seg <= SEG_9;
                4'hA: seg <= SEG_A;
                4'hB: seg <= SEG_b;
                4'hC: seg <= SEG_C2;
                4'hD: seg <= SEG_d;
                4'hE: seg <= SEG_E;
                4'hF: seg <= SEG_F;
                default: seg <= SEG_0;
            endcase
        end
        else begin
            // No exclude switch on, turn off display
            an <= 4'b1111;
            seg <= 8'b11111111;
        end
    end
    
endmodule