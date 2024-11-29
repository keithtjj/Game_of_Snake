`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Keith Tan
// 
// Create Date: 12.11.2024 15:33:34
// Design Name: 
// Module Name: Snake_Control
// Project Name: 
// Target Devices: BASYS 3 board
// Tool Versions: Vivado 2015.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Snake_Control(
    input CLK,
    input RESET,
    input PAUSE,
    input GAMEMODE,
    input [1:0] MSM_state,
    input [1:0] NavSM_state,
    input [14:0] Target_Addr,   // X,Y
    input [9:0] ADDR_X,
    input [8:0] ADDR_Y,
    output Reach_Target,
    output reg Touch_Self,
    output reg [11:0] COLOUR
    );
    
    // Nav SM states
    parameter RIGHT = 2'b00;
    parameter UP = 2'b01;
    parameter DOWN = 2'b10;
    parameter LEFT = 2'b11;
    
    parameter LENGTH_MAX = 20;
    parameter LENGTH_MIN = 5;
    reg [4:0] Length;

    reg [8:0] SNAKE_X [0:LENGTH_MAX-1];
    reg [7:0] SNAKE_Y [0:LENGTH_MAX-1];
    parameter MAX_Y = 119;
    parameter MAX_X = 159;
    
    parameter START_Y = 60;
    parameter START_X = 80;
    
    wire Trig_Snake;
    wire Enable_Snake;
    assign Enable_Snake = !PAUSE && MSM_state == 2'b01;
    
    // 21-bit counter
    Generic_counter # (.COUNTER_WIDTH(24),
                       .COUNTER_MAX(5000000)
                       ) 
                       Bit21Counter (
                       .CLK(CLK),
                       .RESET(1'b0),
                       .ENABLE(Enable_Snake),
                       .TRIG_OUT(Trig_Snake)                     
                       );
    
    // Replace top snake state with new one based on direction
    always@(posedge CLK) begin
        if (RESET) begin
            // set the initial state of the snake
            SNAKE_X[0] <= START_X;
            SNAKE_Y[0] <= START_Y;
        end
        else if (Trig_Snake) begin
            case (NavSM_state)
                UP : begin
                    if (SNAKE_Y[0] == 0) SNAKE_Y[0] <= MAX_Y;
                    else SNAKE_Y[0] <= SNAKE_Y[0] - 1;
                end

                LEFT : begin
                    if (SNAKE_X[0] == 0) SNAKE_X[0] <= MAX_X;
                    else SNAKE_X[0] <= SNAKE_X[0] - 1;                            
                end

                DOWN : begin
                    if (SNAKE_Y[0] == MAX_Y) SNAKE_Y[0] <= 0;
                    else SNAKE_Y[0] <= SNAKE_Y[0] + 1;
                end

                RIGHT : begin
                    if (SNAKE_X[0] == MAX_X) SNAKE_X[0] <= 0;
                    else SNAKE_X[0] <= SNAKE_X[0] + 1; 
                end  
                
                default : SNAKE_X[0] <= SNAKE_X[0];
            endcase
        end
    end
    
    // Shift the Snake State positions
    genvar Snake_Seg;
    generate
        for(Snake_Seg = 0; Snake_Seg < LENGTH_MAX - 1; Snake_Seg = Snake_Seg+1)
            begin: Snake_Seg_SHIFT
                always@(posedge CLK) begin
                    if (RESET | MSM_state == 2'd0) begin
                        SNAKE_X[Snake_Seg+1] <= START_X;
                        SNAKE_Y[Snake_Seg+1] <= START_Y;
                    end
                    else if(Trig_Snake) begin
                        SNAKE_X[Snake_Seg+1] <= SNAKE_X[Snake_Seg];
                        SNAKE_Y[Snake_Seg+1] <= SNAKE_Y[Snake_Seg];
                    end
                end
        end       
    endgenerate
    
    wire Pixel_contains_target;
    assign Pixel_contains_target = ADDR_X[9:2] == Target_Addr[14:7] && ADDR_Y[8:2] == Target_Addr[6:0];

    wire Pixel_contains_head;
    assign Pixel_contains_head = ADDR_X[9:2] == SNAKE_X[0] && ADDR_Y[8:2] == SNAKE_Y[0];

    assign Reach_Target = Pixel_contains_target && Pixel_contains_head;

    always@(posedge CLK) begin
        if(Length < LENGTH_MIN || RESET) Length <= LENGTH_MIN;
        else if(Reach_Target && Length < LENGTH_MAX) Length <= Length + 1;
    end

    reg Pixel_contains_body;
    reg [5:0] body;
    always@(posedge CLK) begin
        Pixel_contains_body <= 0;
        Touch_Self <= 0;
        for(body = 1; body < Length; body = body+1) begin
            if(ADDR_X[9:2] == SNAKE_X[body] && ADDR_Y[8:2] == SNAKE_Y[body])
              Pixel_contains_body <= 1;
            if(SNAKE_X[0] == SNAKE_X[body] && SNAKE_Y[0] == SNAKE_Y[body] 
              && (SNAKE_X[0] != START_X || SNAKE_Y[0] != START_Y) && body > 2)
              Touch_Self <= 1;
        end
    end
            
    always@(posedge CLK) begin
        COLOUR <= 12'hF00;
        if(Pixel_contains_target) COLOUR <= 12'h00F;
        else begin
            if(Pixel_contains_head) COLOUR <= 12'h0F0;
            else if(Pixel_contains_body) COLOUR <= 12'h0FF;
        end
    end

endmodule
