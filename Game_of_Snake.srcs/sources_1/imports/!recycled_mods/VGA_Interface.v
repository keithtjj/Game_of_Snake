`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Keith Tan
// 
// Create Date: 21.10.2024 14:52:02
// Design Name: 
// Module Name: VGA_Interface
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


module VGA_Interface(
    input CLK,
    input [11:0] COLOUR_IN,
    output reg [11:0] COLOUR_OUT,
    output reg HS,
    output reg VS,
    output reg [9:0] ADDR_H,        // Pixel X coordinate
    output reg [8:0] ADDR_V         // Pixel Y coordinate
    );
    
    initial COLOUR_OUT = 0;
    initial HS = 0;
    initial VS = 0;
    initial ADDR_H = 0;
    initial ADDR_V = 0;
    
    //Time for Vertical Lines
    parameter VertTimeToPulseWidthEnd = 10'd2;
    parameter VertTimeToBackPorchEnd = 10'd31;
    parameter VertTimeToDisplayTimeEnd = 10'd511;
    parameter VertTimeToFrontPorchEnd = 10'd521;
    
    //Time for Front Horizontal Lines
    parameter HorzTimeToPulseWidthEnd = 10'd96;
    parameter HorzTimeToBackPorchEnd = 10'd144;
    parameter HorzTimeToDisplayTimeEnd = 10'd784;
    parameter HorzTimeToFrontPorchEnd = 10'd800;
    
    parameter H_Max = 640;
    parameter V_Max = 480;
    
    wire [9:0] Horz_Count;
    wire Horz_Trig;
    wire [9:0] Vert_Count;
    wire Vert_Trig;
    wire CLK_25MHz;
    
    // 25 MHz CLK
    Generic_counter # (.COUNTER_WIDTH(2), 
                       .COUNTER_MAX(3)
                       )
                       Clock_25MHz (
                       .CLK(CLK),
                       .RESET(1'b0),
                       .ENABLE(1'b1),
                       .TRIG_OUT(CLK_25MHz)
                       );
    
    // 800 counter for horizontal
    Generic_counter # (.COUNTER_WIDTH(10), 
                       .COUNTER_MAX(800 - 1)
                       )
                       Horz_Counter800 (
                       .CLK(CLK_25MHz),
                       .RESET(1'b0),
                       .ENABLE(1'b1),
                       .COUNT(Horz_Count),
                       .TRIG_OUT(Horz_Trig)
                       );
    // 521 counter for vertical
   Generic_counter # (.COUNTER_WIDTH(10), 
                      .COUNTER_MAX(521 - 1)
                      )
                      Vert_Counter521 (
                      .CLK(Horz_Trig),
                      .RESET(1'b0),
                      .ENABLE(1'b1),
                      .COUNT(Vert_Count),
                      .TRIG_OUT(Vert_Trig)
                      );
    // HS & VS                  
    always@(posedge CLK) begin
        if(Horz_Count < HorzTimeToPulseWidthEnd) 
            HS <= 0;
        else HS <= 1;
    end
    
    always@(posedge CLK) begin
        if(Vert_Count < VertTimeToPulseWidthEnd) 
            VS <= 0;
        else VS <= 1;
    end

    // Colour out
    always@(posedge CLK) begin
        if(HorzTimeToBackPorchEnd < Horz_Count && Horz_Count < HorzTimeToDisplayTimeEnd
            && VertTimeToBackPorchEnd < Vert_Count && Vert_Count< VertTimeToDisplayTimeEnd) 
            COLOUR_OUT <= COLOUR_IN;
        else COLOUR_OUT <= 0;
    end
    
    // Addresses
    always@(posedge CLK_25MHz) begin
        if(HorzTimeToBackPorchEnd < Horz_Count && Horz_Count < HorzTimeToDisplayTimeEnd) 
            ADDR_H <= ADDR_H + 1;
        else ADDR_H <= 0;
    end
    
    always@(posedge CLK_25MHz) begin
        if(ADDR_H == H_Max-1) begin
            if(VertTimeToBackPorchEnd < Vert_Count && Vert_Count< VertTimeToDisplayTimeEnd) 
                ADDR_V <= ADDR_V + 1;
            else if(ADDR_V == V_Max-1) ADDR_V <= 0;
        end
    end
    
endmodule
