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
                SEG_E2 = 8'b00000110,
                SEG_F = 8'b10001110,  // Digit F (for 15)
                // Anode control patterns (active low)
                AN_1 = 4'b1110,       // Rightmost display active
                AN_2 = 4'b1101,       // Second from right active
                AN_3 = 4'b1011,       // Second from left active
                AN_4 = 4'b0111;       // Leftmost display active
    
    // Clock generation for different speeds
    wire move_right_clk;    // 0.65s movement clock (≈1.54Hz)
    wire move_left_clk;     // 1.30s movement clock (≈0.77Hz)
    wire blink_5hz;         // 5Hz blink clock
    wire blink_11hz;        // 11Hz blink clock
    
    // LED movement controller signals
    reg [3:0] ex;           // Position of 'ex' (0 to 15)
    reg [3:0] prev_ex;      // Previous position of 'ex'
    reg direction;          // 0 = moving right, 1 = moving left
    reg movement_active;    // Whether ex is currently moving
    reg btnR_prev;          // For edge detection

    reg ending_mode;        // Whether the ending mode is active
    reg btnC_prev;
    wire both_buttons;
    assign both_buttons = btnR && btnC;
    
    // Initialize the system
    initial begin
        // Turn off all 7-segment displays
        an = 4'b1111;
        seg = 8'b11111111;
        
        // Set LEDs 12 through 2 on, except for LED 8
        led = 16'b0001_1110_1111_1100;
        
        // Initialize LED movement variables
        ex = 8;            // Start at LED15
        prev_ex = 8;       // Previous position is same initially
        direction = 0;      // Start moving right
        movement_active = 0; // Movement not started yet
        btnR_prev = 0;      // Button not pressed initially

        ending_mode = 0;    // Ending mode not active
        btnC_prev = 0;      // Button not pressed initially
    end
    
    // Generate the different clock frequencies
    
    // Clock for moving right (0.65s per move) ≈ 1.54Hz
    clock_gen #(32500000) move_right_generator (
        .clk(clk),
        .slow_clock(move_right_clk)
    );
    
    // Clock for moving left (1.30s per move) ≈ 0.77Hz
    clock_gen #(65000000) move_left_generator (
        .clk(clk),
        .slow_clock(move_left_clk)
    );
    
    // Clock for 5Hz blinking
    clock_gen #(10000000) blink_5hz_generator (
        .clk(clk),
        .slow_clock(blink_5hz)
    );
    
    // Clock for 11Hz blinking
    clock_gen #(4545455) blink_11hz_generator (
        .clk(clk),
        .slow_clock(blink_11hz)
    );
    
    // Button press detector - Start the movement on button press
    always @(posedge clk) begin
        btnR_prev <= btnR;
        btnC_prev <= btnC;
        if(both_buttons && !ending_mode)begin
        ending_mode <= 1;
        end
        // Detect rising edge of btnR
        else if (btnR && !btnR_prev && !ending_mode) begin
            movement_active <= 1;  // Start the movement
        end
    end

        // Single clock domain movement controller
    reg right_clk_edge, left_clk_edge;  // Edge detection for clock signals
    reg move_right_clk_prev, move_left_clk_prev;
    
    always @(posedge clk) begin
        // Edge detection for movement clocks
        move_right_clk_prev <= move_right_clk;
        move_left_clk_prev <= move_left_clk;
        
        // Detect rising edges of the movement clocks
        right_clk_edge <= move_right_clk && !move_right_clk_prev;
        left_clk_edge <= move_left_clk && !move_left_clk_prev;
        
        
        // Movement control using detected edges
        if (movement_active) begin
            if (direction == 0 && right_clk_edge) begin  // Moving right (toward LED0)
                if (ex == 0) begin
                    direction <= 1;  // Change direction when reaching LED0
                end
                else begin
                    prev_ex <= ex;
                    ex <= ex - 1;  // Move right (decrement position)
                end
            end
            else if (direction == 1 && left_clk_edge) begin  // Moving left (toward LED15)
                if (ex == 15) begin
                    direction <= 0;  // Change direction when reaching LED15
                end
                else begin
                    prev_ex <= ex;
                    ex <= ex + 1;  // Move left (increment position)
                end
            end
        end
    end

               // LED control based on position of 'ex'
        always @(posedge clk) begin
            if (movement_active) begin
                // Start with the base pattern: LEDs 12-2 ON except 8
                led = 16'b0001_1111_1111_1100;
                
                // Handle different ex positions with case statement
                case(ex)
                    // For positions 13-15: Default pattern + blinking at ex position
                    4'd13: led[13] = blink_5hz;
                    4'd14: led[14] = blink_5hz;
                    4'd15: led[15] = blink_5hz;
                    
                    // For positions 0-1: Default pattern + blinking at ex position
                    4'd0: led[0] = blink_11hz;
                    4'd1: led[1] = blink_11hz;
                    
                    // For positions 2-12: Turn OFF the LED at ex position
                    // (except 8 which is already off in default pattern)
                    4'd2: led[2] = 1'b0;
                    4'd3: led[3] = 1'b0;
                    4'd4: led[4] = 1'b0;
                    4'd5: led[5] = 1'b0;
                    4'd6: led[6] = 1'b0;
                    4'd7: led[7] = 1'b0;
                    4'd8: led[8] = 1'b0;
                    4'd9: led[9] = 1'b0;
                    4'd10: led[10] = 1'b0;
                    4'd11: led[11] = 1'b0;
                    4'd12: led[12] = 1'b0;
                    
                    default: led = 16'b0001_1110_1111_1100; // Default pattern
                endcase
                
                // Always ensure previous position is ON if within range 2-12 (except 8)
                if (prev_ex != ex && prev_ex >= 2 && prev_ex <= 12 && prev_ex != 8) begin
                    led[prev_ex] = 1'b1;
                end
            end
            else begin
                // Not moving: show default pattern
                led = 16'b0001_1110_1111_1100;
            end
        end 

    always @(posedge clk) begin
        // Check if any switch is on
        if (ending_mode)begin
            case (ex)
                4'h0: begin seg <= SEG_E2; an = 4'b0110; end
                4'h1: begin seg <= SEG_E2; an = 4'b0110; end
                4'h2:  begin seg <= SEG_C2; an = 4'b1001; end
                4'h3:  begin seg <= SEG_C2; an = 4'b1001; end
                4'h4:  begin seg <= SEG_C2; an = 4'b1001; end
                4'h5:  begin seg <= SEG_C2; an = 4'b1001; end
                4'h6:  begin seg <= SEG_C2; an = 4'b1001; end
                4'h7:  begin seg <= SEG_C2; an = 4'b1001; end
                4'h8:  begin seg <= SEG_C2; an = 4'b1001; end
                4'h9:  begin seg <= SEG_C2; an = 4'b1001; end
                4'hA: begin seg <= SEG_C2; an = 4'b1001; end
                4'hB: begin seg <= SEG_C2; an = 4'b1001; end
                4'hC: begin seg <= SEG_C2; an = 4'b1001; end
                4'hD: begin seg <= SEG_E2; an = 4'b0110; end
                4'hE: begin seg <= SEG_E2; an = 4'b0110; end
                4'hF: begin seg <= SEG_E2; an = 4'b0110; end
                default: seg <= SEG_0;
            endcase
        end
        else if (|sw) begin
            // Enable rightmost display
            an <= AN_1&AN_2&AN_4;
            
            // Display the current 'ex' position in hexadecimal
            case (ex)
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
            // No switch is on, turn off display
            an <= 4'b1111;
            seg <= 8'b11111111;
        end
    end
endmodule

// Generic clock generator module
module clock_gen #(
    parameter COUNT_MAX = 25000000  // Default for 2Hz from 100MHz
)(
    input clk,                // 100MHz input clock
    output reg slow_clock     // Output clock
);
    // Calculate number of bits needed for counter
    localparam COUNTER_WIDTH = $clog2(COUNT_MAX);
    
    // Counter to generate slower clock
    reg [COUNTER_WIDTH-1:0] counter = 0;
    
    initial begin
        slow_clock = 0;
    end
    
    always @(posedge clk) begin
        if (counter >= COUNT_MAX - 1) begin
            counter <= 0;
            slow_clock <= ~slow_clock;
        end
        else begin
            counter <= counter + 1;
        end
    end
endmodule