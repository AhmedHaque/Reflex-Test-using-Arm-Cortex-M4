 	.data

	.global prompt
	.global mydata

prompt:	.string "Waiting for interrupt", 0xA, 0xD, 0
instructions: .string 0xA, 0xD,"Instructions:", 0xA, 0xD, "There are two players to this game:", 0xA, 0xD, "Spacebar Player - Yellow", 0xA, 0xD, "Tiva Switch Button Player - Blue", 0xA, 0xD, 0xA, 0xD, "Once the green light on the Tiva board is turned on, each player will try to press their button(spacebar or Tiva switch) first." , 0xA, 0xD, "The player who presses their button first will have their color displayed on the Tiva.", 0xA, 0xD, "If a player presses their button before the Tiva light turns green, then once the other player(the winning player) presses their button, a red light will appear for a moment before showing the winning player's color.", 0xA, 0xD,"If both players are early, a red light will be shown", 0xA, 0xD, 0xA, 0xD, "Basically the game is to press your button immediatley after the light turns green, if you do it early then you automatically lose.", 0xA, 0xD, 0xA, 0xD, "Press G to play!!!", 0xA, 0xD, 0
game_state:		.byte 0x00 ;before: 0000(0), starting: 0001(1), during: 0010(2), after: 0011(3), ended: 0111(7)
early_flag:		.byte 0x00 ;no players: 0000(0), tiva: 0010(2), keyboard: 0100(4), both: 0110(6)
winner_flag:	.byte 0x00 ; not yet: 0000(0), tiva: 0001(1), keyboard: 0010(2)
tiva_wins:		.byte 0x00	;number containing tivas wins
keyboard_wins:	.byte 0x00	;number containing keyboardss wins
number_of_times_played: .byte 0x00 ;number containing number of times played
finished_message: .string  0xA, 0xD,"The game has finished!", 0xA, 0xD, "Press C to play again, or press X to stop playing", 0xA, 0xD, 0
number_of_times_played_message: .string 0xA, 0xD,"Number of times this game has been played: " ,0
number_of_times_played_str: .string "     "
keyboard_finished_msg: .string 0xA, 0xD, "Spacebar player(keyboard) number of wins: ", 0
keyboard_wins_str:		.string "     " ;where i will store the str of keyboard wins
tiva_finished_msg: .string 0xA, 0xD, "Switch button player(Tiva SW1) number of wins: ", 0
tiva_wins_str:		.string "     " ;where i will store the str of tiva wins
goodbye:		.string 0xA, 0xD, "Goodbye!", 0xA, 0xD, 0


mydata:			.byte	0x20	; This is where you can store data.
			; The .byte assembler directive stores a byte
			; (initialized to 0x20 in this case) at the label
			; mydata.  Halfwords & Words can be stored using the
			; directives .half & .word
			

	.text

	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler			; This is needed for Lab #6
	.global simple_read_character	; read_character modified for interrupts
	.global output_character		; This is from your Lab #4 Library
	.global read_string				; This is from your Lab #4 Library
	.global output_string			; This is from your Lab #4 Library
	.global uart_init				; This is from your Lab #4 Library
	.global tiva_init
	.global lab5
	.global int2string
	.global divison
	.global illuminate_RGB_LED
	.global output_character


ptr_to_prompt:		.word prompt
ptr_to_mydata:		.word mydata
ptr_to_instructions: .word instructions
ptr_to_game_state:      .word game_state
ptr_to_early_flag:      .word early_flag
ptr_to_winner_flag:     .word winner_flag
ptr_to_tiva_wins:       .word tiva_wins
ptr_to_keyboard_wins:   .word keyboard_wins
ptr_to_finished_message:      .word finished_message
ptr_to_keyboard_finished_msg: .word keyboard_finished_msg
ptr_to_keyboard_wins_str:     .word keyboard_wins_str
ptr_to_tiva_finished_msg:     .word tiva_finished_msg
ptr_to_tiva_wins_str:         .word tiva_wins_str
ptr_to_goodbye:               .word goodbye
ptr_to_number_of_times_played: .word number_of_times_played
ptr_to_number_of_times_played_message: .word number_of_times_played_message
ptr_to_number_of_times_played_str: .word number_of_times_played_str

lab5:				; This is your main routine which is called from
				; your C wrapper.
	PUSH {r4-r12,lr}   	; Preserve registers to adhere to the AAPCS

	bl tiva_init
 	bl uart_init
	bl uart_interrupt_init
	bl gpio_interrupt_init


start_game
	;Start of game
	;Output instructions
	ldr r6, ptr_to_instructions
	MOV r0, r6
	BL output_string
	
	;Zero all flags
	;zero game_state flag
	ldr r7, ptr_to_game_state
	MOV r8, #0
	STRB r8, [r7]

	;zero early flag
	ldr r7, ptr_to_early_flag
	MOV r8, #0
	STRB r8, [r7]

	;zero winner flag
	ldr r7, ptr_to_winner_flag
	MOV r8, #0
	STRB r8, [r7]


G_Loop:
	;if game_state == starting:
	;	continue
	;else:
	;	loop again
	ldr r7, ptr_to_game_state
	LDRB r8, [r7]

	CMP r8, #1 ;game_state == starting
	BNE G_Loop



	;Turn off RGB LED
	MOV r0, #0
	BL illuminate_RGB_LED
	
	;count to one
	BL count_one_second

	;output green RGB LED
	MOV r0, #2
	BL illuminate_RGB_LED

	;game_state = during
	ldr r7, ptr_to_game_state
	MOV r8, #2 ;game_state = during
	STRB r8, [r7]




Main_Loop:

	;if early_flag == both:
	;	winner = not yet
	;	game_state = after
	;	branch end_of_game
	ldr r7, ptr_to_early_flag
	LDRB r8, [r7]
	CMP r8, #6 ;early_flag ==  both
	BEQ Main_Loop_both_early

	;if game_state == after:
	;	branch end_of_game
	ldr r7, ptr_to_game_state
	LDRB r8, [r7]
	CMP r8, #3 ;game_state ==  after
	BEQ end_of_game

	B Main_Loop




Main_Loop_both_early:
	;winner = not yet
	ldr r7, ptr_to_winner_flag
	MOV r8, #0 ;winner = not yet
	STRB r8, [r7]

	;game_state = after
	ldr r7, ptr_to_game_state
	MOV r8, #3 ;game_state = after
	STRB r8, [r7]
	B end_of_game	;branch end_of_game



end_of_game:
	;if early == both:
	;	output red
	;	branch replay_or_exit
	ldr r7, ptr_to_early_flag
	LDRB r8, [r7]
	CMP r8, #6 ;early_flag ==  both
	BEQ end_of_game_both_early


	;if early == tiva:
	;	output red
	;	count to one
	;	keyboard_wins += 1
	;	output yellow
	;	branch replay_