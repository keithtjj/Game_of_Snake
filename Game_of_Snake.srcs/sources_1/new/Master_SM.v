`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Keith Tan
// 
// Create Date: 11.11.2024 15:14:53
// Design Name: 
// Module Name: Master_SM
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


module Master_SM(
    input CLK,
    input RESET,
    input BTN_U,
    input BTN_D,
    input BTN_L,
    input BTN_R,
    input [6:0] Score,
    input [1:0] Lose_Cons,
    output [1:0] MSM_state
    );
    
    // MSM states
    parameter IDLE = 2'b00;
    parameter PLAY = 2'b01;
    parameter WIN = 2'b10;
    parameter LOSE = 2'b11;
    
    parameter WIN_SCORE = 6'd20;
    
    reg [1:0] Curr_state;
    reg [1:0] Next_state;
    
    assign MSM_state = Curr_state;
    
    always@(posedge CLK) begin
        if(RESET) Curr_state <= IDLE;
        else Curr_state <= Next_state;
    end
    
    always@(posedge CLK) begin
        case(MSM_state)
            IDLE : begin
                if(BTN_U || BTN_D || BTN_L || BTN_R) Next_state <= PLAY;
                else Next_state <= IDLE;
            end
            
            PLAY : begin
                if(Score >= 6'd20) Next_state <= WIN;
                else begin
                    if(Lose_Cons > 0) Next_state <= LOSE;
                    else Next_state <= PLAY;
                end
            end
            
            WIN : Next_state <= WIN;
            
            LOSE : Next_state <= LOSE;
                        
            default : Next_state <= IDLE;
        endcase
    end
    
endmodule
