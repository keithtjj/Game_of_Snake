# Game_of_Snake
Basic snake game developed for the BASYS 3 FPGA board as part of a university course.  
Programmed using Vivado 2015.2

**WARNING: FLASHING LIGHTS!**  
Modify `VGA_Control.v` to remove flashing IDLE and LOSE screens if needed.

## How to Use
- Open in Vivado 
- Generate bitstream
- Program device

## Features
- Get a score of 20 to win
- Snake grows up to 20 segments
- Reset function
- Pause function
- 60 sec timed mode
- Game over when snake touches its own body

## Controls
- Press directional buttons to start (T18, U17, W19, T17)
- Directional buttons to move 
- Slide switch V17 to pause game
- Slide switch R2 to reset game
- Slide switch T1 to toggle timed mode
