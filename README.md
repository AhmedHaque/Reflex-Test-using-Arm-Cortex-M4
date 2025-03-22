# Reflex-Test-using-Arm-Cortex-M4
## Description
- The following program was created using a Tiva TM4C123G with code programming in Arm. The  code was created to test the functioning of Interrupts and how to implement it.
## Program Overview 
- The following program we have a two-player game to test the reflexes of the players. Spacebar player is yellow while the Tiva switch button 1 player is blue. The game starts by asking the players to click on G to begin the game. The players click their respective buttons once the LED turns green. If either player clicks before the color changes to green then the other player gets a point and if both players click before it turns green, then none of the players receive a point. Once the LED turns green, when the first player who clicks on it changes to their respective color. After each round players are given the option to either restart the game or end it.
## Subroutine Description
- Handle_G(): The following routine checks if the G key is pressed and the state is in the Starting State. If the conditions are met, then the state of the game is changed to the Starting State. The main loop can leave the Main loop where it waits for the state not to be the Before State.
- Count_one_second(): Loops for 1 second then changes the LED to green so that players can click their respective buttons. This also changes the state from Starting State to During State. 
Handle_SW1(): If the game is in During state and the Tiva SW1 is pressed first then the LED turns to Blue. If it is clicked in the Starting State, then the winner is the spacebar player. The game is set to After State once it has been clicked. 
- Handle_Space():If the game is in During State and the Spacebar is pressed first then the LED turns to Yellow. If it is clicked in the Starting State, then the winner is the Tiva SW1 player. The game is set to After State once it has been clicked. 
- Handle_C(): Once the game is in the After State and the C key is pressed it resets the state to the Before State and restarts the game by displaying the information, waiting for the G key to be clicked. 
- Handle_X(): Once the state is in the After State and the X key is pressed, it changes the state to Ended and displays the scores.
