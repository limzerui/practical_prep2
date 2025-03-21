module top(
    input clk,
    input [2:0] sw,
    input btnL,
    input btnD,
    input btnR,
    output reg [3:0] an,
    output reg dp,
    output reg [7:0] seg,
    output reg [14:0] led,
    output reg maxled
    );

    parameter   SEG_L = 8'b11001111,  
                SEG_C = 8'b10100111, 
                SEG_R = 8'b10101111,
                SEG_D = 8'b10100001,
                SEG_U = 8'b11100011,
                AN_1 = 4'b1110,
                AN_2 = 4'b1101,
                AN_3 = 4'b1011,
                AN_4 = 4'b0111,
                AN_5 = 4'b1011;
    
    wire clockspeed;
    slw_clk dut(clk, clockspeed);

    wire ld0speed;
    ld0clock ld0(clk, ld0speed);
    
    wire ld1speed;
    ld1clock ld1(clk, ld1speed);

    wire ld2speed;
    ld2clock ld2(clk, ld2speed);

    reg [4:0] led_count;
    reg trigger;
    reg [4:0] an_state;

    initial begin
        led_count = 0;
        trigger = 0;
        an_state = 0;
    end

    always @(posedge clockspeed)begin
           if(led_count < 15)begin
            led_count <= led_count + 1; 
           end
           else begin
            led_count <= 15;
    end
    end

    always @(posedge clk)begin
        case (led_count)
                    0: begin
                led <= 15'b000000000000000;
            end
            1: begin
                led <= 15'b000000000000001;
            end
            2: begin
                led <= 15'b000000000000011;
            end
            3: begin
                led <= 15'b000000000000111;
            end
            4: begin
                led <= 15'b000000000001111;
            end
            5: begin
                led <= 15'b000000000011111;
            end
            6: begin
                led <= 15'b000000000111111;
            end 
            7: begin
                led <= 15'b000000001111111;
            end
            8: begin
                led <= 15'b000000011111111;
            end
            9: begin
                led <= 15'b000000111111111;
            end
            10: begin
                led <= 15'b000001111111111;
            end
            11: begin
                led <= 15'b000011111111111;
            end
            12: begin
                led <= 15'b000111111111111;
            end
            13: begin
                led <= 15'b001111111111111;
            end
            14: begin
                led <= 15'b011111111111111;
            end
            15: begin
                if (sw[2:0] == 3'b000) begin
                    led <= 15'b111111111111111;
                end
                else if (sw[0] == 1'b1) begin
                    led[14:1] <= 14'b11111111111111;
                    led[0] <= ld0speed;
                end
                else if (sw[1] == 1'b1) begin
                    led[14:2] <= 13'b1111111111111;
                    led[1] <= ld1speed;
                    led[0] <= 1'b1;
                end
                else if (sw[2] == 1'b1) begin
                    led[14:3] <= 12'b111111111111;
                    led[2] <= ld2speed;
                    led[1:0] <= 2'b11;
                end
                trigger <= 1;
                an_state <= 5'b00001;
            end
        endcase
    end

    always @(*){
        if(trigger == 1) begin
            case(an_state)
                5'b00001: begin
                    an <= AN_1;
                    seg <= SEG_L;
                    if(btnL == 1) begin
                        an_state <= 5'b00010;
                    end
                end
                5'b00010: begin
                    an <= AN_2;
                    seg <= SEG_C;
                    if(btnC == 1) an_state <= 5'b00011;
                end
                5'b00011: begin
                    an <= AN_3;
                    seg <= SEG_R;
                    if(btnR == 1) an_state <= 5'b00100;
                end
                5'b00100: begin
                    an <= AN_4;
                    seg <= SEG_C;
                    if(btnC) an_state <= 5'b00101;
                end
                5'b00101: begin
                    an <= AN_1;
                    seg <= SEG_U;
                    if(btnU) an_state <= 5'b00110;
                end
                5'b00110: begin
                    an <= AN_2;
                    seg <= SEG_D;
                    if(btnD) an_state <= 5'b00111;
                end
                5'b00111: begin
                    an <= AN_3;
                    seg <= SEG_C;
                    maxled <= 1;
                end
            endcase
        end
        else begin
            an <= 4'b1111;
            seg <= 8'b11111111;
        end
    }
endmodule

// 5Hz clock
module slw_clk(
    input clk,
    output reg SLOW_CLOCK
);

    reg[23:0] counter;

    initial begin
        counter = 0;
        SLOW_CLOCK = 0;
    end

    always @(posedge clk) begin
        if(counter == 10000000) begin
            SLOW_CLOCK <= ~SLOW_CLOCK;
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end
endmodule

//1Hz clock
module ld0clock(
    input CLOCK,
    output reg SLOW_CLOCK1
    );

    reg [25:0] COUNT1;

    initial begin
        SLOW_CLOCK1 = 0;
        COUNT1 = 0;
    end

    always @ (posedge CLOCK) begin
        if (COUNT1 == 50000000 ) begin
            SLOW_CLOCK1 <= ~SLOW_CLOCK1;
            COUNT1 <= 0;
            end
        else begin
            COUNT1 <= COUNT1 + 1;
            end
     end
       
endmodule

//10Hz clock
module ld1clock(
    input CLOCK,
    output reg SLOW_CLOCK2
    );

    reg [22:0] COUNT2;

    initial begin
        SLOW_CLOCK2 = 0;
        COUNT2 = 0;
    end

    always @ (posedge CLOCK) begin
        if (COUNT2 == 5000000 ) begin
            SLOW_CLOCK2 <= ~SLOW_CLOCK2;
            COUNT2 <= 0;
            end
        else begin
            COUNT2 <= COUNT2 + 1;
            end
     end
       
endmodule

module ld2clock(
    input CLOCK,
    output reg SLOW_CLOCK3
    );

    reg [18:0] COUNT3;

    initial begin
        SLOW_CLOCK3 = 0;
        COUNT3 = 0;
    end

    always @ (posedge CLOCK) begin
        if (COUNT3 == 500000 ) begin
            SLOW_CLOCK3 <= ~SLOW_CLOCK3;
            COUNT3 <= 0;
            end
        else begin
            COUNT3 <= COUNT3 + 1;
            end
     end
       
endmodule