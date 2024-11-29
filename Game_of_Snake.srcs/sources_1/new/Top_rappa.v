`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Keith Tan
// 
// Create Date: 11.11.2024 15:06:34
// Design Name: 
// Module Name: Top_rappa
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


module Top_rappa(
    input CLK,
    input BTN_U,
    input BTN_D,
    input BTN_L,
    input BTN_R,
    input RESET,
    input PAUSE,
    input GAMEMODE,
    output [11:0] COLOUR_OUT,
    output HS,
    output VS,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] HEX_OUT
    );
    
    wire [6:0] Score;
    wire [1:0] MSM_state;
    wire [1:0] NavSM_state;
    
    wire [9:0] ADDR_X;
    wire [8:0] ADDR_Y;
    wire [11:0] COLOUR_SNAKE;
    wire [14:0] Target_Addr;
    wire Reach_Target;
    wire [1:0] Lose_Cons;
        
    Master_SM Master_SM(
        .CLK(CLK),
        .RESET(RESET),
        .BTN_U(BTN_U),
        .BTN_D(BTN_D),
        .BTN_L(BTN_L),
        .BTN_R(BTN_R),
        .Score(Score),
        .Lose_Cons(Lose_Cons),
        .MSM_state(MSM_state)
        );

    Nav_SM Nav_SM(
        .CLK(CLK),
        .RESET(RESET),
        .BTN_U(BTN_U),
        .BTN_D(BTN_D),
        .BTN_L(BTN_L),
        .BTN_R(BTN_R),
        .NavSM_state(NavSM_state)
        );
    
    Target_Gen Target_Gen(
        .CLK(CLK),
        .RESET(RESET),
        .MSM_state(MSM_state),
        .Reach_Target(Reach_Target),
        .Target_Addr(Target_Addr)   // X,Y
        );
    
    Score_Counter Score_Counter(
        .CLK(CLK),
        .RESET(RESET),
        .Reach_Target(Reach_Target),
        .MSM_state(MSM_state),
        .PAUSE(PAUSE),
        .GAMEMODE(GAMEMODE),
        .Overtime(Lose_Cons[1]),
        .Score(Score),
        .SEG_SELECT_OUT(SEG_SELECT_OUT),
        .HEX_OUT(HEX_OUT)
        );
    
    Snake_Control Snake_Control(
        .CLK(CLK),
        .RESET(RESET),
        .PAUSE(PAUSE),
        .MSM_state(MSM_state),
        .NavSM_state(NavSM_state),
        .Target_Addr(Target_Addr),   // X,Y
        .ADDR_X(ADDR_X),
        .ADDR_Y(ADDR_Y),
        .Reach_Target(Reach_Target),
        .Touch_Self(Lose_Cons[0]),
        .COLOUR(COLOUR_SNAKE)
        );

    VGA_Control VGA_Control(
        .CLK(CLK),
        .MSM_state(MSM_state),
        .COLOUR(COLOUR_SNAKE),
        .ADDR_X(ADDR_X),
        .ADDR_Y(ADDR_Y),
        .HS(HS),
        .VS(VS),
        .COLOUR_OUT(COLOUR_OUT)
        );

endmodule