`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Keith Tan
// 
// Create Date: 11.11.2024 15:14:53
// Design Name: 
// Module Name: Nav_SM
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


module Nav_SM(
    input CLK,
    input RESET,
    input BTN_U,
    input BTN_D,
    input BTN_L,
    input BTN_R,
    output [1:0] NavSM_state
    );
    
    parameter RIGHT = 2'b00;
    parameter UP = 2'b01;
    parameter DOWN = 2'b10;
    parameter LEFT = 2'b11;
    
    reg [1:0] Curr_state;
    reg [1:0] Next_state;
    
    assign NavSM_state = Curr_state;
    
    always@(posedge CLK) begin
        if(RESET) Curr_state = RIGHT;
        else Curr_state = Next_state;
    end
    
    always@(posedge CLK) begin
        case(NavSM_state)
            RIGHT : begin
                if(BTN_U) Next_state <= UP;
                else begin
                    if(BTN_D) Next_state <= DOWN;
                    else Next_state <= RIGHT;
                end
            end
            
            LEFT : begin
                if(BTN_U) Next_state <= UP;
                else begin
                    if(BTN_D) Next_state <= DOWN;
                    else Next_state <= LEFT;
                end
            end
            
            UP : begin
                if(BTN_R) Next_state <= RIGHT;
                else begin
                    if(BTN_L) Next_state <= LEFT;
                    else Next_state <= UP;
                end
            end
                                    
            DOWN : begin
                if(BTN_R) Next_state <= RIGHT;
                else begin
                    if(BTN_L) Next_state <= LEFT;
                    else Next_state <= DOWN;
                end
            end
                        
            default : Next_state <= RIGHT;
        endcase
    end
    
endmodule
