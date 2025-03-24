// Top module - Main controller for the Basys3 board
module top(
    input clk,              // 100MHz system clock
    input [2:0] sw,         // 3 switches for mode selection
    input btnL,             // Left button input
    input btnD,             // Down button input
    input btnR,             // Right button input
    input btnC,             // Center button input
    input btnU,             // Up button input
    output reg [3:0] an,    // 4 anode control signals for 7-segment displays
    output reg [7:0] seg,   // 8 cathode control signals for 7-segment displays (includes decimal point)
    output reg [14:0] led,  // 15 individual LEDs
    output reg maxled       // Additional LED indicator for maximum state
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
                // Anode control patterns (active low)
                AN_1 = 4'b1110,       // Rightmost display active
                AN_2 = 4'b1101,       // Second from right active
                AN_3 = 4'b1011,       // Second from left active
                AN_4 = 4'b0111,       // Leftmost display active
                AN_5 = 4'b1011;       // Same as AN_3 (appears to be redundant)
                
    // Get display control signals from the seven segment controller module
    wire[7:0] seg_subtask;
    wire[3:0] an_subtask;
    seven_seg_controller ssc(clk, seg_subtask, an_subtask);           
    
    // Different clock speed signals for various animations/effects
    wire clockspeed;                // 5Hz clock
    slw_clk dut(clk, clockspeed);

    wire ld0speed;                  // 1Hz clock
    ld0clock ld0(clk, ld0speed);
    
    wire ld1speed;                  // 10Hz clock
    ld1clock ld1(clk, ld1speed);

    wire ld2speed;                  // 100Hz clock (from ld2clock module)
    ld2clock ld2(clk, ld2speed);

    // State registers
    reg [4:0] led_count;            // Counter for LED sequence animation (0-15)
    reg [3:0] taskbflag = 4'b0;     // Task/state flags indicating current program state

    // Initialize registers
    initial begin
        led_count = 0;              // Start with no LEDs lit
        led = 15'b0;                // Initialize all LEDs to off
        maxled = 1'b0;              // Initialize max indicator LED to off
    end

    // LED sequence animation control - advances LED count at 5Hz
    always @(posedge clockspeed)begin
           if(led_count < 15)begin
            led_count <= led_count + 1;  // Increment LED count until max (15)
           end
           else begin
            led_count <= 15;             // Stay at maximum
    end
    end

    // LED display pattern control based on led_count value
    // This creates a "filling" animation from right to left
    always @(posedge clk)begin
        case (led_count)
                    0: begin
                led <= 15'b000000000000000;  // All LEDs off
            end
            1: begin
                led <= 15'b000000000000001;  // Rightmost LED on
            end
            2: begin
                led <= 15'b000000000000011;  // Two rightmost LEDs on
            end
            3: begin
                led <= 15'b000000000000111;  // Three rightmost LEDs on
            end
            4: begin
                led <= 15'b000000000001111;  // Four rightmost LEDs on
            end
            5: begin
                led <= 15'b000000000011111;  // Five rightmost LEDs on
            end
            6: begin
                led <= 15'b000000000111111;  // Six rightmost LEDs on
            end 
            7: begin
                led <= 15'b000000001111111;  // Seven rightmost LEDs on
            end
            8: begin
                led <= 15'b000000011111111;  // Eight rightmost LEDs on
            end
            9: begin
                led <= 15'b000000111111111;  // Nine rightmost LEDs on
            end
            10: begin
                led <= 15'b000001111111111;  // Ten rightmost LEDs on
            end
            11: begin
                led <= 15'b000011111111111;  // Eleven rightmost LEDs on
            end
            12: begin
                led <= 15'b000111111111111;  // Twelve rightmost LEDs on
            end
            13: begin
                led <= 15'b001111111111111;  // Thirteen rightmost LEDs on
            end
            14: begin
                led <= 15'b011111111111111;  // Fourteen rightmost LEDs on
            end
            15: begin
                // At maximum LED count, behavior depends on switch settings
                if (sw[2:0] == 3'b000) begin
                    led <= 15'b111111111111111;  // All LEDs on
                    taskbflag[3] <= 1'b1;        // Set highest task flag bit
                end
                else if (sw[0] == 1'b1) begin
                    led[14:1] <= 14'b11111111111111;  // All but rightmost LED on
                    led[0] <= ld0speed;               // Rightmost LED blinks at 1Hz
                end
                else if (sw[1] == 1'b1) begin
                    led[14:2] <= 13'b1111111111111;   // All but two rightmost LEDs on
                    led[1] <= ld1speed;               // Second LED blinks at 10Hz
                    led[0] <= 1'b1;                   // Rightmost LED always on
                end
                else if (sw[2] == 1'b1) begin
                    led[14:3] <= 12'b111111111111;    // All but three rightmost LEDs on
                    led[2] <= ld2speed;               // Third LED blinks at 100Hz
                    led[1:0] <= 2'b11;                // Two rightmost LEDs always on
                end
                
            end
        endcase
    end

    // 7-segment display control and task state machine
    always @(*)begin
        if(taskbflag == 4'b0000) begin
            an[3:0] <= 4'b1111;     // All displays off initially
            seg[7:0] <= 7'b1111111; // All segments off
        end
        else if (taskbflag == 4'b1000) begin
            // First task state - display animation from seven_seg_controller
            an <= an_subtask;       // Use the outputs from seven_seg_controller
            seg <= seg_subtask; 
            if (btnD == 1) begin
                taskbflag[2] <= 1;  // Progress to next state if down button pressed
                end
        end
        else if (taskbflag == 4'b1100) begin
                    an[3:0] <= AN_1;        // Enable rightmost display
                    seg[6:0] <= SEG_L;      // Display 'L'
                    if (btnL == 1) begin
                        taskbflag[1] <= 1;  // Progress to next state if left button pressed
                        end
                    end
        else if (taskbflag == 4'b1110) begin
            an[3:0] <= AN_2;                // Enable second display
            seg[6:0] <= SEG_R;              // Display 'R'
            if (btnR == 1) begin
                taskbflag[0] <= 1;          // Progress to next state if right button pressed
                end
            end
        else if (taskbflag == 4'b1111) begin
            an[3:0] <= AN_3;                // Enable third display
            seg[6:0] <= SEG_U;              // Display 'U'
            maxled <= 1'b1;                 // Turn on max indicator LED
            end
    end
endmodule

// 9Hz Clock Generator Module
module ld9clock(
    input CLOCK,              // 100MHz input clock
    output reg SLOW_CLOCK9    // 9Hz output clock
);

    // For 9Hz from 100MHz:
    // 100,000,000 / (2 * 9) - 1 = 5,555,555
    // Need 23 bits for counter: 2^23 = 8,388,608 > 5,555,555
    reg [22:0] COUNT9;

    initial begin
        SLOW_CLOCK9 = 0;
        COUNT9 = 0;
    end

    always @ (posedge CLOCK) begin
        if (COUNT9 == 5555555) begin  // Toggle at this threshold for 9Hz
            SLOW_CLOCK9 <= ~SLOW_CLOCK9;  // Toggle output
            COUNT9 <= 0;                  // Reset counter
        end
        else begin
            COUNT9 <= COUNT9 + 1;         // Increment counter
        end
    end
       
endmodule

// 5Hz clock generator module
module slw_clk(
    input clk,                // 100MHz input clock
    output reg SLOW_CLOCK     // 5Hz output clock
);

    // For 5Hz from 100MHz:
    // 100,000,000 / (2 * 5) = 10,000,000
    reg[23:0] counter;        // 24-bit counter needed (2^24 > 10M)

    initial begin
        counter = 0;
        SLOW_CLOCK = 0;
    end

    always @(posedge clk) begin
        if(counter == 10000000) begin    // Toggle every 10M cycles for 5Hz
            SLOW_CLOCK <= ~SLOW_CLOCK;   // Toggle output
            counter <= 0;                // Reset counter
        end
        else begin
            counter <= counter + 1;      // Increment counter
        end
    end
endmodule

// 1Hz clock generator module
module ld0clock(
    input CLOCK,             // 100MHz input clock
    output reg SLOW_CLOCK1   // 1Hz output clock
    );

    // For 1Hz from 100MHz:
    // 100,000,000 / (2 * 1) = 50,000,000
    reg [25:0] COUNT1;       // 26-bit counter needed (2^26 > 50M)

    initial begin
        SLOW_CLOCK1 = 0;
        COUNT1 = 0;
    end

    always @ (posedge CLOCK) begin
        if (COUNT1 == 50000000 ) begin    // Toggle every 50M cycles for 1Hz
            SLOW_CLOCK1 <= ~SLOW_CLOCK1;  // Toggle output
            COUNT1 <= 0;                  // Reset counter
            end
        else begin
            COUNT1 <= COUNT1 + 1;         // Increment counter
            end
     end
       
endmodule

// 10Hz clock generator module
module ld1clock(
    input CLOCK,             // 100MHz input clock
    output reg SLOW_CLOCK2   // 10Hz output clock
    );

    // For 10Hz from 100MHz:
    // 100,000,000 / (2 * 10) = 5,000,000
    reg [22:0] COUNT2;       // 23-bit counter needed (2^23 > 5M)

    initial begin
        SLOW_CLOCK2 = 0;
        COUNT2 = 0;
    end

    always @ (posedge CLOCK) begin
        if (COUNT2 == 5000000 ) begin     // Toggle every 5M cycles for 10Hz
            SLOW_CLOCK2 <= ~SLOW_CLOCK2;  // Toggle output
            COUNT2 <= 0;                  // Reset counter
            end
        else begin
            COUNT2 <= COUNT2 + 1;         // Increment counter
            end
     end
       
endmodule

// 100Hz clock generator module
module ld2clock(
    input CLOCK,             // 100MHz input clock
    output reg SLOW_CLOCK3   // 100Hz output clock
    );

    // For 100Hz from 100MHz:
    // 100,000,000 / (2 * 100) = 500,000
    reg [18:0] COUNT3;       // 19-bit counter needed (2^19 > 500K)

    initial begin
        SLOW_CLOCK3 = 0;
        COUNT3 = 0;
    end

    always @ (posedge CLOCK) begin
        if (COUNT3 == 500000 ) begin      // Toggle every 500K cycles for 100Hz
            SLOW_CLOCK3 <= ~SLOW_CLOCK3;  // Toggle output
            COUNT3 <= 0;                  // Reset counter
            end
        else begin
            COUNT3 <= COUNT3 + 1;         // Increment counter
            end
     end
       
endmodule

// Clock divider for display refresh timing (~333Hz)
module clk_divider(
    input CLOCK,             // 100MHz input clock
    output reg SLOW_CLOCK3   // ~333Hz output clock (display refresh rate)
    );

    // For ~333Hz from 100MHz:
    // 100,000,000 / (2 * 333) ≈ 150,000
    reg [18:0] COUNT3;       // 19-bit counter needed (2^19 > 150K)

    initial begin
        SLOW_CLOCK3 = 0;
        COUNT3 = 0;
    end

    always @ (posedge CLOCK) begin
        if (COUNT3 == 149999 ) begin      // Toggle every 150K cycles for ~333Hz
            SLOW_CLOCK3 <= ~SLOW_CLOCK3;  // Toggle output
            COUNT3 <= 0;                  // Reset counter
            end
        else begin
            COUNT3 <= COUNT3 + 1;         // Increment counter
            end
     end
       
endmodule

// Controller for the 7-segment display animation
module seven_seg_controller(
    input clk,                // 100MHz input clock
    output reg [7:0] seg,     // Segment control (active low)
    output reg [3:0] an       // Anode control (active low)
);
  // Get the animation clock (~333Hz refresh rate)
  wire animation_clk;
  clk_divider cd(
        clk,
        animation_clk);
        
  // 2-bit counter to cycle through the 4 displays
  reg [1:0] digit;
  always @(posedge animation_clk) begin
    digit <= digit + 1;      // Cycle through digits 0-3
  end
  
  // Display different patterns based on the current active digit
  always @(*) begin
    case(digit)
      2'b00: begin
        an  = 4'b1110;       // Activate rightmost display
        seg = 8'b11111001;   // Display '1'
      end
      2'b01: begin
        an  = 4'b1101;       // Activate second display from right
        seg = 8'b11111001;   // Display '1'
      end
      2'b10: begin
        an  = 4'b1011;       // Activate third display from right
        seg = 8'b00110000;   // Custom pattern (appears to be 'E')
      end
      2'b11: begin
        an  = 4'b0111;       // Activate leftmost display
        seg = 8'b10010010;   // Display '5'
      end
      default: begin
        an  = 4'b1111;       // All displays off
        seg = 8'b1111111;    // All segments off
      end
    endcase
  end
endmodule