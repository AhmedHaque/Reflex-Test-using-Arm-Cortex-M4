	.data

memory_for_read_str:.string "                 ",0

	.text
	.global uart_init
	.global gpio_btn_and_LED_init
	.global output_character
	.global read_character
	.global read_string
	.global output_string
	.global read_from_push_btns
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global read_tiva_pushbutton
	.global division
	.global multiplication
	.global tiva_init
	.global int2string
U0FR: 	.equ 0x18	; UART0 Flag Register

ptr_to_readstr:			.word memory_for_read_str

uart_init:
	;-----------------------------
	;Initializes the user UART for use
	;_____________________________
	PUSH {r4-r12,lr}	; Spill registers to stack

          ; Your code is placed here
	MOV r4, #0xE000
	MOVT r4, #0x400F
	LDR r5, [r4, #0x618] ;Provide clock to UART0
	ORR r5, r5, #1
	STR r5, [r4, #0x618]

	LDR r5, [r4, #0x608] ;Enable clock to PortA
	ORR r5, r5, #1
	STR r5, [r4, #0x608]

	MOV r4, #0xC000 ;Disable UART0 Control
	MOVT r4, #0x4000
	LDR r5, [r4, #0x30]
	AND r5, r5, #0
	STR r5, [r4, #0x30]

	 ;Set UART0_IBRD_R for 115,200 baud
	LDR r5, [r4, #0x24]
	ORR r5, r5, #8
	STR r5, [r4, #0x24]

	;Set UART0_FBRD_R for 115,200 baud
	LDR r5, [r4, #0x28]
	ORR r5, r5, #44
	STR r5, [r4, #0x28]

	;Use System Clock
	LDR r5, [r4, #0xFC8]
	AND r5, r5, #0
	STR r5, [r4, #0xFC8]

	;Use 8-bit word length, 1 stop bit, no parity
	LDR r5, [r4, #0x2C]
	ORR r5, r5, #0x60
	STR r5, [r4, #0x2C]

	;Enable UART0 Control
	LDR r5, [r4, #0x30]
	MOV r7, #0x301
	ORR r5, r5, r7
	STR r5, [r4, #0x30]

	MOV r4, #0x4000 ;Make PA0 and PA1 as Digital Ports
	MOVT r4, #0x4000
	LDR r5, [r4, #0x51C]
	ORR r5, r5, #0x03
	STR r5, [r4, #0x51C]

	LDR r5, [r4, #0x420] ;Change PA0,PA1 to Use an Alternate Function
	ORR r5, r5, #0x03
	STR r5, [r4, #0x420]

	LDR r5, [r4, #0x52C] ;Configure PA0 and PA1 for UART
	ORR r5, r5, #0x11
	STR r5, [r4, #0x52C]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

tiva_init:
	;-----------------------------------------------
	;HELPER FUNCTION FOR gpio_btn_and_LED_init
	;_______________________________________________

	PUSH {r4-r12,lr}	; Spill registers to stack

	;-----------------------------
	;ENABLE THE CLOCK IN PORT F
	;_____________________________
	MOV r5, #0xE000
    MOVT r5, #0x400F
	;Enable the clock for port F
	LDRB r6, [r5, #0x608]
	ORR r6, #32
	STRB r6, [r5, #0x608]



	;-----------------------------
	;ENABLE THE PINS FOR IO IN PORT F
	;_____________________________
	MOV r5, #0x5000
	MOVT r5, #0x4002
	;Enabling the pins
	LDRB r6, [r5, #0x400]
	ORR r6, #14	;we set bits 1, 2, and 3 to 1 so that we set the rgb pins for output
	BIC r6, #0x10 ;we bitclear the 4th bit(starting from 0) so that it is 0 for input
	STRB r6, [r5, #0x400]



	;-----------------------------------------------
	;SETTING THE PINS FOR IO IN PORT F TO BE DIGITAL
	;_______________________________________________
	;r5 ALREADY has Port F's address in it!!!
	LDRB r6, [r5, #0x51C]
	ORR r6, #30 ;Setting all the bits to be 1 so they can be in digital mode
	STRB r6, [r5, #0x51C]

	; Enabling the Pull Up Resistor for the button.
	LDRB r6, [r5, #0x510]
	ORR r6, r6, #0x10
	STRB r6, [r5, #0x510]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

gpio_btn_and_LED_init:
	;---------------------------------------------------------------------------
	; Initializes the four push buttons on the Alice EduBase board, the four
	; LEDs on the AliceEduBase board, the momentary push button on the Tiva board (SW1)
	; , and the RGB LED on the Tiva board.
	;___________________________________________________________________________
	PUSH {r4-r12,lr}	; Spill registers to stack


	;---------------------------------------------------------------------------
	;PORT B IS THE ALICE EDUBASE BOARD LEDS!!!
	;PORT D IS THE ALICE EDUBASE BOARD BUTTONS!!!
	;PORT F IS THE TIVA BOARD BUTTONS AND RGB LEDS!!!
	;___________________________________________________________________________



	;-------------------------------------------------
	;PORT B IS THE ALICE EDUBASE BOARD LEDS!!!
	;_________________________________________________
	;-----------------------------
	;ENABLE THE CLOCK IN PORT B
	;_____________________________
	MOV r5, #0xE000
    MOVT r5, #0x400F
	;Enable the clock for port B
	LDRB r6, [r5, #0x608]
	ORR r6, #2
	STRB r6, [r5, #0x608]

	;-----------------------------
	;ENABLE THE PINS FOR IO IN PORT B
	;_____________________________
	MOV r5, #0x5000
	MOVT r5, #0x4000
	;Enabling the pins
	LDRB r6, [r5, #0x400]
	ORR r6, #0xF ; we set bits 0, 1, 2, and 3 to 1 so that we set the LED pins for output
	STRB r6, [r5, #0x400]

	;-----------------------------------------------
	;SETTING THE PINS FOR IO IN PORT B TO BE DIGITAL
	;_______________________________________________
	;r5 ALREADY has Port B's address in it!!!
	LDRB r6, [r5, #0x51C]
	ORR r6, #0xF ;Setting all the bits to be 1 so they can be in digital mode
	STRB r6, [r5, #0x51C]




	;-------------------------------------------------
	;PORT D IS THE ALICE EDUBASE BOARD BUTTONS!!!
	;_________________________________________________
	;-----------------------------
	;ENABLE THE CLOCK IN PORT D
	;_____________________________
	MOV r5, #0xE000
    MOVT r5, #0x400F
	;Enable the clock for port D
	LDRB r6, [r5, #0x608]
	ORR r6, #8
	STRB r6, [r5, #0x608]

	;-----------------------------
	;ENABLE THE PINS FOR IO IN PORT D
	;_____________________________
	MOV r5, #0x7000
	MOVT r5, #0x4000
	;Enabling the pins
	LDRB r6, [r5, #0x400]
	BIC r6, #0xF ; we set bits 0, 1, 2, and 3 to 0 so that we set the button pins for input
	STRB r6, [r5, #0x400]

	;-----------------------------------------------
	;SETTING THE PINS FOR IO IN PORT D TO BE DIGITAL
	;_______________________________________________
	;r5 ALREADY has Port D's address in it!!!
	LDRB r6, [r5, #0x51C]
	ORR r6, #0xF ;Setting all the bits to be 1 so they can be in digital mode
	STRB r6, [r5, #0x51C]


	;-------------------------------------------------
	;PORT F IS THE TIVA BOARD BUTTONS AND RGB LEDS!!!
	;_________________________________________________
	BL tiva_init

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

output_character:
	;---------------------------------------------------------------------------
	;Transmits a character passed into the routine in r0 to PuTTy via the UART.
	;___________________________________________________________________________
	PUSH {r4-r12,lr}	; Spill registers to stack

	MOV r5, #0xC000
	MOVT r5, #0x4000

load_r1: LDRB r1, [r5, #U0FR]
	MOV r3, #32 ; this is so we can do the masking on bit #5,
	MOV r4, #0
	AND r4, r1, r3	;AND r1 and r3 and store result in r4, if r4 is 32 that means
					; mask bit(bit #5)is 1 and not 0, if it is 0 that means r4 = 0 and we are good to write

	CMP r4, #32
	BEQ load_r1 ; redo loop until mask bit is 0

	STRB r0, [r5]

	;0x4000C000 is the base address

          ; Your code is placed here

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

read_character:
	;---------------------------------------------------------------------------
	;Reads a character from PuTTy via the UART, and returns the character in r0.
	;___________________________________________________________________________
	PUSH {r4-r12,lr}	; Spill registers to stack

	MOV r5, #0xC000
	MOVT r5, #0x4000

read_bro: LDRB r1, [r5, #U0FR]
	MOV r3, #16 ; this is so we can do the masking on bit #4,
	MOV r4, #0
	AND r4, r1, r3	;AND r1 and r3 and store result in r4, if r4 is 16 that means
					; mask bit(bit #4)is 1 and not 0, if it is 0 that means r4 = 0 and we are good to write

	CMP r4, #16
	BEQ read_bro ; redo loop until mask bit is 0

	LDRB r0, [r5]
		; Your code to receive a character obtained from the keyboard
		; in PuTTy is placed here.  The character is returned in r0.

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

read_string:
    ;-------------------------------------------------------------------------------------------------
    ;Reads a string entered in PuTTy and stores it as a null-terminated string in memory.
    ;The user terminates the string by hitting Enter. The base address of the string should be passed
    ;into the routine in r0. The carriage return should NOT be stored in the string.
    ;__________________________________________________________________________________________________

    PUSH {r4-r12,lr}    ; Spill registers to stack

          ; Your code is placed here
    BL free_memory_for_read_str
    MOV r10, r0 ;put r0 in r10 cuz r0 changes with read_character and output_character
    MOV r11, #0
reading:
    BL read_character
    CMP r0, #13 ;Carriage Return
    BEQ end_read_string
    BL output_character


    STRB r0, [r10, r11]
    ADD r11, r11, #1
    B reading

end_read_string:
    MOV r0, #0x0A
    BL output_character
    MOV r0, #0x0D
    BL output_character


    MOV r0, #0x00
    STRB r0, [r10, r11]

    MOV r0, r10 ;put r0 back

    POP {r4-r12,lr}      ; Restore registers from stack
    MOV pc, lr

output_string:
    ;-------------------------------------------------------------------------------------------------
    ;Displays a null-terminated string in PuTTy. The base address of the string should be
    ;passed into the routine in r0.
    ;__________________________________________________________________________________________________


    PUSH {r4-r12,lr}    ; Spill registers to stack

          ; Your code is placed here
    MOV r10, r0 ;put r0 in r10 cuz r0 changes with output_character
    MOV r11, #0  ;offset counter
outputting: LDRB r8, [r10, r11]
    CMP r8, #0x00 ;Compare with NULL
    BEQ end_output_string
    MOV r0, r8
    BL output_character
    ADD r11, r11, #1
    B outputting

end_output_string:


    MOV r0, r10 ;put r0 back cuz why not.

    POP {r4-r12,lr}      ; Restore registers from stack
    MOV pc, lr

read_from_push_btns:
	;---------------------------------------------------------------------------
	; Reads the four push buttons (Switches 2-5) on the ALICE EDUBASE BOARD.
	; The buttons are mapped to Port D (Pins 0-3):
	;
	;THIS IS WHAT THE VALUE RETURNED IN r0 MEANS:
	;
	;   BUTTON2 (Pin 3) -> Bit 3
	;   BUTTON3 (Pin 2) -> Bit 2
	;   BUTTON4 (Pin 1) -> Bit 1
	;   BUTTON5 (Pin 0) -> Bit 0
	;
	;	WHEN A BUTTON IS PRESSED, ITS CORRESPONDING BIT WILL EQUAL 1.
	;
	; For example, if r0 = 0xA (binary 1010), then bits 1 and 3 are one,
	; indicating BUTTON2 and BUTTON4 were pressed.
	;---------------------------------------------------------------------------

	PUSH {r4-r12,lr}	; Spill registers to stack


	;Port D's address
	MOV r5, #0x7000
	MOVT r5, #0x4000

	;READ from data register to see when button is pushed
	LDRB r6, [r5, #0x3FC]
	MOV r0, r6

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

illuminate_LEDs:
	;---------------------------------------------------------------------------
	;Illuminates the four ALICE EDUBASE BOARD LEDs. The pattern indicating which
	;LEDs to illuminate is passed into the routine in r0.
	;Bit 0 -> LED0
	;Bit 1 -> LED1
	;Bit 2 -> LED2
	;Bit 3 -> LED3
	;
	;For example putting 0x5 into r0 will turn on LED0 and LED2,
	; this is because 0x5 = 0101
	;___________________________________________________________________________

	PUSH {r4-r12,lr}	; Spill registers to stack

	;Port B's address
	MOV r5, #0x5000
	MOVT r5, #0x4000

    LDRB r6, [r5, #0x3FC]
	BIC r6, #0xF ;I BIT CLEAR HERE IN CASE A BIT THAT NEEDS
				;TO BE 0 HAS BEEN PREVIOUSLY SET TO 1

	ORR r6, r6, r0 ; SETTING THE PINS FOR GPIO DATA REGISTER USE
	STRB r6, [r5, #0x3FC]


	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

illuminate_RGB_LED:
	;---------------------------------------------------------------------------
	;Illuminates the RBG LED on the TIVA board. The color to be displayed is
	;passed into the routine in r0 as such:
	;	0 -> OFF
	;	1 -> Red
	;	2 -> Green
	;	3 -> Blue
	;	4 -> Purple
	;	5 -> Yellow
	;	6 -> White
	; Port F, Pin 1 - Red, Pin 2 - Blue, Pin 3 - Green
	; Port F address: 0x40025000
	;___________________________________________________________________________

	PUSH {r4-r12,lr}	; Spill registers to stack

	;r10 is where we will put the color choice
	MOV r10, #0

	;OFF
	CMP r0, #0
	BEQ TURN_ON_LIGHTS

	;RED
	CMP r0, #1
	BEQ SET_RED

	;GREEN
	CMP r0, #2
	BEQ SET_GREEN

	;BLUE
	CMP r0, #3
	BEQ SET_BLUE

	;PURPLE
	CMP r0, #4
	BEQ SET_PURPLE

	;YELLOW
	CMP r0, #5
	BEQ SET_YELLOW

	;WHITE
	CMP r0, #6
	BEQ SET_WHITE

	;IF NO COLOR IS CHOSEN,
	;WE WILL DEFAULT TO WHITE
	B SET_WHITE

SET_RED:
	;Turning on RED pin to make RED
	MOV r10, #0x2
	B TURN_ON_LIGHTS

SET_GREEN:
	;Turning on GREEN pin to make GREEN
	MOV r10, #0x8
	B TURN_ON_LIGHTS

SET_BLUE:
	;Turning on BLUE pin to make BLUE
	MOV r10, #0x4
	B TURN_ON_LIGHTS

SET_PURPLE:
	;Turning on RED and BLUE pin to make PURPLE
	MOV r10, #0x6
	B TURN_ON_LIGHTS

SET_YELLOW:
	;Turning on RED and GREEN pin to make YELLOW
	MOV r10, #0xA
	B TURN_ON_LIGHTS

SET_WHITE:
	;Turning on RED and GREEN and BLUE pin to make WHITE
	MOV r10, #0xE
	B TURN_ON_LIGHTS



TURN_ON_LIGHTS:
	;Port F's address
	MOV r5, #0x5000
	MOVT r5, #0x4002

    LDRB r6, [r5, #0x3FC]
	BIC r6, #0xE ;I BIT CLEAR HERE IN CASE A BIT THAT NEEDS
				;TO BE 0 HAS BEEN PREVIOUSLY SET TO 1

	ORR r6, r6, r10 ; SETTING THE PINS FOR GPIO DATA REGISTER USE
	STRB r6, [r5, #0x3FC]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

read_tiva_pushbutton:
	;---------------------------------------------------------------------------
	;Reads from the momentary push button (SW1) on the Tiva board, and
	;returns a one (1) in r0 if the button is currently being pressed
	;, and a zero (0) if it is not.
	;___________________________________________________________________________

	PUSH {r4-r12,lr}	; Spill registers to stack

	;Port F's address
	MOV r5, #0x5000
	MOVT r5, #0x4002


	;READ from data register to see when button is pushed
	LDRB r6, [r5, #0x3FC]
	AND r6, r6, #0x10
	EOR r0, r6, #0x10 ; When this bit is 0, the button is being pressed
	CMP r0, #0x10
	BEQ set_to_one

set_to_zero:
	MOV r0, #0
	B end_of_tiva

set_to_one:
	MOV r0, #1
						;when this bit is 1, the button is not being pressed
end_of_tiva:			;we will return a 1 into r0 if the button is being pressed
						;and we will return a 0 into r0 if the button is not being pressed

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

division:
	;---------------------------------------------------------------------
	;Accepts a dividend in r0 and a divisor in r1 and returns the quotient in r0. Both
	;the dividend and divisor are unsigned integers that will NOT exceed 15 bits
	;
	; Divison works like Dividend/Divisor = Quotient
	; Remainder is in r3!
	;_____________________________________________________________________
	PUSH {r4-r12,lr}	; Spill registers to stack

	; Your code for the division routine goes here.
	MOV r2, #15 ;initialize counter to 15
	MOV r5, #0 ;initialize quotient to 0
	; Divison works like Dividend/Divisor = Quotient
	; r0 is the divident, r1 is the divisor, I will return the Quotient into r0
	LSL r1, #15
	MOV r3, r0 ;initialize your remainder to dividend

REMEQREMMINUSDIVISOR: SUB r3, r3, r1 ; remainder = remainder - divisor

	CMP r3, #0 		;is remainder < 0?

	BLT SMALLREM ; Yes remainder is < 0

	LSL r5, #1   ;Logical left shift quotient by 1

	ORR r5, #1 ;set quotient's LSB to 1

	B LOGICALRIGHTSHIFTDIVISOR

SMALLREM:	ADD r3, r3, r1 ; remainder = remainder + divisor
			LSL r5, #1 ;Logical left shift quotient by 1

LOGICALRIGHTSHIFTDIVISOR: LSR r1, #1

	CMP r2, #0

	BEQ DONEE
	SUB r2, r2, #1
	B REMEQREMMINUSDIVISOR

DONEE: MOV r0, r5

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

multiplication:
	;---------------------------------------------------------------------
	;Accepts two unsigned integers in r0 and r1 and returns the product in
	;r0. Both integers passed into the routine will NOT exceed 15 bits.
	;_____________________________________________________________________
	PUSH {r4-r12,lr}	; Spill registers to stack

	; Your code for the multiplication routine goes here.
	MOV r2, #0  ; Initialize result to 0


	MOV r5, #0  ; Initialize the counter to 0

	MOV r5, r1  ; Copy r1 into the counter (r5)

MULT_LOOP:
	CMP r5, #0  		; Check if counter (r5) > 0
	BEQ MULT_DONE 	; If counter is 0, exit loop

	ADD r2, r2, r0  	; Add r0 to the result (r2)
	SUB r5, r5, #1  	; Decrement the counter by 1

	B MULT_LOOP  		; Repeat the loop

MULT_DONE:
	MOV r0, r2  	; Copy result (r2) into r0

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

free_memory_for_read_str:
    PUSH {r4-r12,lr}

    LDR r0, ptr_to_readstr
    MOV r4, #0
    MOV r5, #17

clear_loop:
    STRB r4, [r0], #1
    SUB r5, r5, #1
    CMP r5, #0
    BNE clear_loop

    POP {r4-r12,lr}
    