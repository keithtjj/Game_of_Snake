`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Keith Tan
// 
// Create Date: 14.10.2024 15:13:51
// Design Name: 
// Module Name: Multiplexer_4way
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


module Multiplexer_4way(
    input [1:0] CTRL,
    input [4:0] IN0,
    input [4:0] IN1,
    input [4:0] IN2,
    input [4:0] IN3,
    output reg [4:0] OUT
    );
    
    // 4 way multiplxer
    always@(CTRL or IN0 or IN1 or IN2 or IN3) begin
        case(CTRL)
            2'b00: OUT <= IN0;
            2'b01: OUT <= IN1;
            2'b10: OUT <= IN2;
            2'b11: OUT <= IN3;
            default: OUT <= 5'b00000;
        endcase  
    end
endmodule
