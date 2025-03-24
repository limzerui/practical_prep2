`timescale 1ns / 1ps

module top_module (
    input [6:0] A,      // 7-bit input from switches for first operand
    input [6:0] B,      // 7-bit input from switches for second operand
    input pb,           // Push button input for display control
    output [6:0] S,     // 7-bit output to LEDs showing addition result
    output [3:0] an,    // Controls which 7-segment display is active
    output [7:0] seg    // Controls segments of the active 7-segment display
);

    // DR holds the direct result from the 7-bit adder
    wire [6:0] DR;      

    // Instantiate the 7-bit adder to calculate A + B
    my_7_bit_adder adder (
        .A(A),
        .B(B),
        .DR(DR)  // The sum is stored in DR
    );

    // XOR the top 2 bits with push button (inverts them when pb=1)
    // This can be used to demonstrate two's complement representation
    assign S = {DR[6] ^ pb, DR[5] ^ pb, DR[4:0]};

    // Control which 7-segment displays are active based on push button
    // When pb=0: an = 4'b0011 (displays 0,1 active)
    // When pb=1: an = 4'b1100 (displays 2,3 active)
    assign an = pb ? ~4'b0011 : 4'b0011;

    // Fixed pattern for 7-segment display: 8'b10111110 (shows "0")
    assign seg = 8'b10111110;

endmodule

// 1-Bit Full Adder - The fundamental building block of all adders
module my_full_adder (
    input A,       // First input bit
    input B,       // Second input bit
    input CIN,     // Carry in bit from previous stage
    output S,      // Sum output bit 
    output COUT    // Carry out bit to next stage
);
    // Sum is calculated as A XOR B XOR CIN
    // This works because XOR is 1 when odd number of inputs are 1
    assign S = A ^ B ^ CIN;
    
    // Carry out occurs in two cases:
    // 1. When both A and B are 1 (regardless of carry in)
    // 2. When carry in is 1 and either A or B (but not both) is 1
    assign COUT = (A & B) | (CIN & (A ^ B));
endmodule

// 4-Bit LSB Adder - Handles the least significant 4 bits
module my_4_bit_adder (
    input [3:0] A,   // 4-bit first operand
    input [3:0] B,   // 4-bit second operand
    input C0,        // Initial carry in (usually 0 for addition)
    output [3:0] S,  // 4-bit sum
    output C4        // Final carry out (propagates to MSB adder)
);
    // Internal carry wires between full adder stages
    wire C1, C2, C3;

    // Chain 4 full adders together, connecting carry out to next carry in
    my_full_adder fa0 (.A(A[0]), .B(B[0]), .CIN(C0), .S(S[0]), .COUT(C1));
    my_full_adder fa1 (.A(A[1]), .B(B[1]), .CIN(C1), .S(S[1]), .COUT(C2));
    my_full_adder fa2 (.A(A[2]), .B(B[2]), .CIN(C2), .S(S[2]), .COUT(C3));
    my_full_adder fa3 (.A(A[3]), .B(B[3]), .CIN(C3), .S(S[3]), .COUT(C4));
endmodule

// 3-Bit MSB Adder - Handles the most significant 3 bits
module my_3_bit_adder (
    input [2:0] A,   // 3-bit first operand (bits 6:4)
    input [2:0] B,   // 3-bit second operand (bits 6:4)
    input CIN,       // Carry in from the LSB adder (bit C4)
    output [2:0] S   // 3-bit sum result
);
    // Internal carry wires
    wire C1, C2;

    // Chain 3 full adders together
    my_full_adder fa0 (.A(A[0]), .B(B[0]), .CIN(CIN), .S(S[0]), .COUT(C1));
    my_full_adder fa1 (.A(A[1]), .B(B[1]), .CIN(C1), .S(S[1]), .COUT(C2));
    my_full_adder fa2 (.A(A[2]), .B(B[2]), .CIN(C2), .S(S[2]), .COUT()); // No need to connect the final carry out
endmodule

// 7-Bit Parallel Adder - Combines 4-bit LSB and 3-bit MSB adders
module my_7_bit_adder (
    input [6:0] A,    // 7-bit first operand
    input [6:0] B,    // 7-bit second operand
    output [6:0] DR   // 7-bit sum result
);
    // Internal wires to store partial results
    wire [3:0] LSB_Sum;  // Sum from the 4-bit LSB adder
    wire [2:0] MSB_Sum;  // Sum from the 3-bit MSB adder
    wire C4;             // Carry out from LSB that connects to MSB carry in

    // Calculate sum of lower 4 bits (A[3:0] + B[3:0])
    // C0 starts at 0 for standard addition
    my_4_bit_adder lsb_adder (
        .A(A[3:0]), 
        .B(B[3:0]), 
        .C0(1'b0), 
        .S(LSB_Sum), 
        .C4(C4)     // C4 is the carry from bit 3 to bit 4
    );

    // Calculate sum of upper 3 bits (A[6:4] + B[6:4])
    // with carry-in from LSB adder for proper propagation
    my_3_bit_adder msb_adder (
        .A(A[6:4]), 
        .B(B[6:4]), 
        .CIN(C4),   // Carry from LSB becomes the carry-in for MSB
        .S(MSB_Sum)
    );

    // Combine the partial results into final 7-bit sum
    assign DR[3:0] = LSB_Sum;  // Lower 4 bits
    assign DR[6:4] = MSB_Sum;  // Upper 3 bits
endmodule