`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Keith Tan
// 
// Create Date: 11.11.2024 16:14:52
// Design Name: 
// Module Name: Score_Counter
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


module Score_Counter(
    input CLK,
    input RESET,
    input Reach_Target,
    input [1:0] MSM_state,
    input PAUSE,
    input GAMEMODE,
    output Overtime,
    output reg [6:0] Score,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] HEX_OUT
    );

    // Master SM state
    parameter PLAY = 2'b01;
    
    wire [4:0] DecCountAndDOT [3:0];
    wire [4:0] MuxOut;
    wire [1:0] StrobeCount;
    
    wire Trig_Ones_Score;
    wire [3:0] Count_Ones_Score;
    wire Trig_Tens_Score;
    wire [3:0] Count_Tens_Score;
    
    wire Trig_Ones_Time;
    wire [3:0] Count_Ones_Time;
    wire Trig_Tens_Time;
    wire [3:0] Count_Tens_Time;

    always@(posedge CLK) begin
        if(RESET) Score <= 0;
        else if(Reach_Target) Score <= Score + 1; 
    end
    
    assign Overtime = Count_Tens_Time == 6; //&& Count_Ones_Time == 9;
        
    // 4-bit score counters
    Generic_counter # (.COUNTER_WIDTH(4), 
                       .COUNTER_MAX(9)
                       )
                       OnesCounter (
                       .CLK(CLK),
                       .RESET(RESET),
                       .ENABLE(Reach_Target),
                       .TRIG_OUT(Trig_Ones_Score),
                       .COUNT(Count_Ones_Score)
                       );
    
    Generic_counter # (.COUNTER_WIDTH(4), 
                      .COUNTER_MAX(9)
                      )
                      TensCounter (
                      .CLK(CLK),
                      .RESET(RESET),
                      .ENABLE(Trig_Ones_Score),
                      .TRIG_OUT(Trig_Tens_Score),
                      .COUNT(Count_Tens_Score)
                      );
                      
    // 1 sec counter
    Generic_counter # (.COUNTER_WIDTH(27), 
                       .COUNTER_MAX(100000000 - 1)
                       )
                       Sec1Counter (
                       .CLK(CLK),
                       .RESET(RESET),
                       .ENABLE(MSM_state == PLAY && GAMEMODE && !PAUSE),
                       .TRIG_OUT(Trig_1sec)
                       );
                       
    Generic_counter # (.COUNTER_WIDTH(4), 
                          .COUNTER_MAX(9)
                          )
                          TimeOnesCounter (
                          .CLK(CLK),
                          .RESET(RESET),
                          .ENABLE(Trig_1sec),
                          .COUNT(Count_Ones_Time),
                          .TRIG_OUT(Trig_Ones_Time)
                          );
    Generic_counter # (.COUNTER_WIDTH(4), 
                         .COUNTER_MAX(9)
                         )
                         TimeTensCounter (
                         .CLK(CLK),
                         .RESET(RESET),
                         .ENABLE(Trig_Ones_Time),
                         .COUNT(Count_Tens_Time),
                         .TRIG_OUT(Trig_1s)
                         );
    assign DecCountAndDOT[0] = {1'b0, Count_Ones_Score};
    assign DecCountAndDOT[1] = {1'b0, Count_Tens_Score};
    assign DecCountAndDOT[2] = {1'b1, Count_Ones_Time};
    assign DecCountAndDOT[3] = {1'b0, Count_Tens_Time};
    
    // 17-bit counter
    Generic_counter # (.COUNTER_WIDTH(17), 
                       .COUNTER_MAX(99999)
                       )
                       Bit17Counter (
                       .CLK(CLK),
                       .RESET(1'b0),
                       .ENABLE(1'b1),
                       .TRIG_OUT(Seg7_Trig)
                       );
    
    // 2-bit counter
    Generic_counter # (.COUNTER_WIDTH(2), 
                       .COUNTER_MAX(3)
                       )
                       Bit2Counter (
                       .CLK(Seg7_Trig),
                       .RESET(1'b0),
                       .ENABLE(1'b1),
                       .COUNT(StrobeCount)
                       );
    
    Multiplexer_4way Mux4 (.CTRL(StrobeCount),
                           .IN0(DecCountAndDOT[0]),
                           .IN1(DecCountAndDOT[1]),
                           .IN2(DecCountAndDOT[2]),
                           .IN3(DecCountAndDOT[3]),
                           .OUT(MuxOut)
                           );   
                    
    Seg7Display Seg7 (.SEG_SELECT_IN (StrobeCount),
                      .BIN_IN(MuxOut[3:0]),
                      .DOT_IN(MuxOut[4]),
                      .SEG_SELECT_OUT(SEG_SELECT_OUT),
                      .HEX_OUT(HEX_OUT)
                      );
    
endmodule
