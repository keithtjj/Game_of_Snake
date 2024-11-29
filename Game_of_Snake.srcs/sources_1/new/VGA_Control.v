`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Keith Tan
// 
// Create Date: 12.11.2024 22:53:44
// Design Name: 
// Module Name: VGA_Control
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


module VGA_Control(
    input CLK,
    input [1:0] MSM_state,
    input [11:0] COLOUR,
    output wire [9:0] ADDR_X,
    output wire [8:0] ADDR_Y,
    output wire HS,
    output wire VS,
    output wire [11:0] COLOUR_OUT
    );
            
    // MSM states
    parameter IDLE = 2'b00;
    parameter PLAY = 2'b01;
    parameter WIN = 2'b10;
    parameter LOSE = 2'b11;
    
    reg [11:0] COLOUR_IN;
    
    VGA_Interface VGA_Interface(
        .CLK(CLK),
        .COLOUR_IN(COLOUR_IN),
        .ADDR_H(ADDR_X),
        .ADDR_V(ADDR_Y),
        .COLOUR_OUT(COLOUR_OUT),
        .HS(HS),
        .VS(VS)
        );
        
    reg [15:0] FrameCount;   
    always@(posedge CLK) begin
        if (ADDR_Y == 479) begin
            FrameCount <= FrameCount + 1;
        end
    end
    
    reg FadeDir;
    always@(posedge CLK) begin
        case(MSM_state)
            IDLE : begin
                if(FrameCount[15:12] == 4'hF) FadeDir = 1;
                else FadeDir = 0;
                if(FadeDir) COLOUR_IN <= {FrameCount[15:12], 8'h00};
                else COLOUR_IN <= {2'b11 - FrameCount[15:12], 8'h00};
            end
            
            PLAY: COLOUR_IN <= COLOUR;
            
            WIN : begin
                if (ADDR_Y[8:0] > 240) begin
                    if (ADDR_X[9:0] > 320)
                        COLOUR_IN <= FrameCount[15:8] + ADDR_Y[8:0] + ADDR_X [9:0] - 240 - 320;
                    else
                        COLOUR_IN <= FrameCount[15:8] + ADDR_Y[8:0] - ADDR_X[9:0] - 240 + 320;
                end
                else begin
                    if (ADDR_X[9:0] > 320)
                        COLOUR_IN <= FrameCount[15:8] - ADDR_Y[8:0] + ADDR_X[9:0] + 240 - 320;
                    else
                        COLOUR_IN <= FrameCount[15:8] - ADDR_Y[8:0] - ADDR_X[9:0] + 240 + 320;
                end
            end
            
            LOSE : begin
                if(120 < ADDR_Y && ADDR_Y < 361 && 210 < ADDR_X && ADDR_X < 240) COLOUR_IN <= FrameCount [15:8];
                else begin
                    if(360 < ADDR_Y && ADDR_Y < 390 && 210 < ADDR_X && ADDR_X < 420) COLOUR_IN <= FrameCount [15:8];
                    else COLOUR_IN <= 0;
                end
            end
            
            default : COLOUR_IN <= 12'hF00;            
        endcase
    end
    
endmodule
