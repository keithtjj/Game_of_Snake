`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Keith Tan
// 
// Create Date: 11.11.2024 15:45:10
// Design Name: 
// Module Name: generic_LFSR
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


module Generic_LFSR(
    CLK,
    RESET,
    RN_OUT
    );
    
    parameter LFSR_WIDTH = 8;
    parameter SEED = 8'd95;
    
    input CLK;
    input RESET;
    output reg [LFSR_WIDTH-1:0] RN_OUT = SEED;
    
    reg IN;
    always@(posedge CLK) begin
        case(LFSR_WIDTH)
            7: IN = RN_OUT[7] ~^ RN_OUT[6];
            8: IN = RN_OUT[8] ~^ RN_OUT[6] ~^ RN_OUT[5] ~^ RN_OUT[4];
        endcase     
    end
    
    always@(posedge CLK) begin
        RN_OUT = {RN_OUT[LFSR_WIDTH-2:0],IN};
    end
    
endmodule
