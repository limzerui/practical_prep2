`timescale 1ns / 1ps

module my_simulation();

    reg [6:0] A;
    reg [6:0] B;
    reg pb;

    wire [6:0] S;
    wire [3:0] an;
    wire [7:0] seg;

    top_module dut (
        .A(A), 
        .B(B), 
        .pb(pb), 
        .S(S), 
        .an(an), 
        .seg(seg)
    );

    initial begin
      
        A = 7'b0000001; 
        B = 7'b0000010;  
        pb = 0;          
        #100;       

        A = 7'b0000111;  
        B = 7'b0000100;  
        pb = 0;          
        #100;           

       
        A = 7'b0111111;  
        B = 7'b0000001; 
        pb = 0;          
        #100;           

    
        A = 7'b0000010; 
        B = 7'b0000011;  
        pb = 1;          
        #100;           

        A = 7'b0111010;  
        B = 7'b0001011;  
        pb = 1;          
        #100;            

       
        A = 7'b1111111; 
        B = 7'b0000001; 
        pb = 1;          
        #100;           

        $stop;  // End simulation
    end






`timescale 1ns / 1ps

// Testbench for the 7-bit adder implementation
module lab2_adders_tb();
    // Inputs to the device under test
    reg [6:0] A;      // 7-bit first operand
    reg [6:0] B;      // 7-bit second operand
    reg pb;           // Push button for display control
    
    // Outputs from the device under test
    wire [6:0] S;     // 7-bit sum displayed on LEDs
    wire [3:0] an;    // Anode control for 7-segment display
    wire [7:0] seg;   // Segment control for 7-segment display

    // Expected sum for verification
    reg [6:0] expected_sum;
    
    // Instantiate the device under test
    top_module dut (
        .A(A),
        .B(B),
        .pb(pb),
        .S(S),
        .an(an),
        .seg(seg)
    );
    
    // Test procedure
    initial begin
        // Initialize inputs
        A = 7'b0000000;
        B = 7'b0000000;
        pb = 0;
        
        // Test case 1: Adding zeros
        // Expected: 0 + 0 = 0
        #10;
        expected_sum = A + B;
        $display("Test Case 1: A=%b, B=%b, Sum=%b, Expected=%b, Match=%b", 
                 A, B, S, expected_sum, (S == expected_sum));
        
        // Test case 2: Simple addition
        A = 7'b0000101;  // 5 in decimal
        B = 7'b0000011;  // 3 in decimal
        #10;
        expected_sum = A + B;  // Should be 8 (0000_1000)
        $display("Test Case 2: A=%b (%d), B=%b (%d), Sum=%b (%d), Expected=%b (%d), Match=%b", 
                 A, A, B, B, S, S, expected_sum, expected_sum, (S == expected_sum));
        
        // Test case 3: With carry propagation across LSB to MSB
        A = 7'b0001010;  // 10 in decimal
        B = 7'b0001100;  // 12 in decimal
        #10;
        expected_sum = A + B;  // Should be 22 (0001_0110)
        $display("Test Case 3: A=%b (%d), B=%b (%d), Sum=%b (%d), Expected=%b (%d), Match=%b", 
                 A, A, B, B, S, S, expected_sum, expected_sum, (S == expected_sum));
        
        // Test case 4: Larger numbers
        A = 7'b0101010;  // 42 in decimal
        B = 7'b0010101;  // 21 in decimal
        #10;
        expected_sum = A + B;  // Should be 63 (0011_1111)
        $display("Test Case 4: A=%b (%d), B=%b (%d), Sum=%b (%d), Expected=%b (%d), Match=%b", 
                 A, A, B, B, S, S, expected_sum, expected_sum, (S == expected_sum));
        
        // Test case 5: Overflow test (within 7 bits)
        A = 7'b0111111;  // 63 in decimal (max for 6 bits)
        B = 7'b0000001;  // 1 in decimal
        #10;
        expected_sum = A + B;  // Should be 64 (0100_0000)
        $display("Test Case 5: A=%b (%d), B=%b (%d), Sum=%b (%d), Expected=%b (%d), Match=%b", 
                 A, A, B, B, S, S, expected_sum, expected_sum, (S == expected_sum));
        
        // Test case 6: Test the push button (pb = 1)
        // This should invert the top 2 bits of the result
        pb = 1;
        A = 7'b0010101;  // 21 in decimal
        B = 7'b0001010;  // 10 in decimal
        #10;
        expected_sum = 7'b0011111;  // 31 in decimal
        // With pb=1, the actual displayed value will have top 2 bits inverted
        // We expect S = {~expected_sum[6], ~expected_sum[5], expected_sum[4:0]}
        $display("Test Case 6 (pb=1): A=%b (%d), B=%b (%d), Raw Sum=%b (%d)", 
                 A, A, B, B, (A+B), (A+B));
        $display("            Displayed S=%b, Expected display=%b", 
                 S, {~expected_sum[6], ~expected_sum[5], expected_sum[4:0]});
        $display("            Match=%b", (S == {~expected_sum[6], ~expected_sum[5], expected_sum[4:0]}));
        
        // End simulation
        #10 $finish;
    end
endmodule

endmodule