`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Keith Tan
// 
// Create Date: 11.11.2024 15:58:58
// Design Name: 
// Module Name: Target_Gen
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


module Target_Gen(
    input CLK,
    input RESET,
    input [1:0] MSM_state,
    input Reach_Target,
    output reg [14:0] Target_Addr   // X,Y
    );
    
    // Master SM state
    parameter IDLE = 2'b00;
    
    parameter MAX_Y = 119;
    parameter MAX_X = 159;
    
    wire [6:0] RN_Y;
    wire [7:0] RN_X;
    reg [14:0] Addr;
    
    Generic_LFSR # (.LFSR_WIDTH(7))
                    LFSR_7bit (
                    .CLK(CLK),
                    .RESET(RESET),
                    .RN_OUT(RN_Y)
                    );
                   
    Generic_LFSR # (.LFSR_WIDTH(8))
                    LFSR_8bit (
                    .CLK(CLK),
                    .RESET(RESET),
                    .RN_OUT(RN_X)
                    );
    
    always@(posedge CLK) begin
        Addr = {RN_X, RN_Y};
        if(RN_X > MAX_X) Addr = {8'd74, Addr[6:0]};
        if(RN_Y > MAX_Y) Addr = {Addr[14:7], 7'd59};
    end
        
    always@(posedge CLK) begin
        if(MSM_state == IDLE || Reach_Target || RESET) Target_Addr <= Addr;
    end
    
endmodule
