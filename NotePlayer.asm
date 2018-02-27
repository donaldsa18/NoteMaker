;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; NotePlayer.asm ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This NotePlayer.asm is a program for that can read input from a keypad and display it to a screen
; and play four different songs

;;;;;;;;;;;;;;;;;;;;;;;;;;; Assembler directives ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        list  P=PIC18F46K22, F=INHX32, C=160, N=0, ST=OFF, MM=OFF, X=ON
        #include "P18F46K22.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cblock  0x000              	;Beginning of Bank 0.
		COUNT		
		R0
		R1
		R2
		R3
		R4
		KEYCODE
		OLDKEYCODE
		Line
		Char
		KeyToShow
		DelayNoteL
		DelayNoteH
		DelayToggleL
		DelayToggleH
		IntervalL
		IntervalH
		D1_16Done
		MenuNum
		NumZeros
		D1_16H
		D1_16L
		NumRepeatNote
        endc

;;;;;;;;;;;;;;;;;;;;;;;;;;;  ; Vectors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        org  	0x0000           	;Reset vector
        nop							;Required by ICD 3 module
        goto  	Mainline

        org  	0x0008           	;High priority interrupt vector
		goto	$
		;bra  	ISR_i				;Check each timer's ISR

        org  	0x0018              ;Low priority interrupt vector
		goto	$
		;bra  	ISR_i               ;Check each timer's ISR

	org  	0x0030

;String definitions
LCDstr		db 0x38, 0x38, 0x38, 0x38, 0x01, 0x0c, 0x06, 0x00
Hello1		db 0x80, "Hi, this is my  ", 0x00
Hello2		db 0xC0, "Design Project. ", 0x00
BlankTop	db 0x80, "                ", 0x00
BlankBot	db 0xC0, "                ", 0x00
Song1T		db 0x80, "1 for Hot Cross ", 0x00
Song1B		db 0xC0, "Buns            ", 0x00
Song2T		db 0x80, "2 for Mario Bros", 0x00
Song2B		db 0xC0, "Overworld Theme ", 0x00
Song3T		db 0x80, "3 for a sweeping", 0x00
Song3B		db 0xC0, "frequency       ", 0x00
Song4T		db 0x80, "4 for Ode to Joy", 0x00
Song4B		db 0xC0, "                ", 0x00
Task1		db 0x80, "1.Task IV        ", 0x00
Task2		db 0xC0, "2.Task V         ", 0x00
KEY_ASCII	db "A321B654C987D#0*"
SHIFT_KEY 	db "@+fe>-?=<&!b(:/)"
HotCrossBunsSong; use 2 bytes per db to keep the 16-bit wide PM full
		db E41, 	E42
		db E43, 	E44
		db .16,  	P1_2
		db P1_2,  	D41;1
		db D42, 	D43
		db D44, 	.16
		db P1_2,  	P1_2
		db C41, 	C42;2
		db C43, 	C44
		db .24, 	P1_2
		db P1_2,  	E41;3
		db E42, 	E43
		db E44, 	.16
		db P1_2,  	P1_2
		db D41, 	D42;4
		db D43, 	D44
		db .16,  	P1_2
		db P1_2, 	C41;5
		db C42, 	C43
		db C44, 	.24
		db P1_2,  	P1_2
		db C41, 	C42;6
		db C43, 	C44
		db .8,  	C41;7
		db C42, 	C43
		db C44, 	.8
		db C41, 	C42;8
		db C43, 	C44
		db .8,  	C41;9
		db C42, 	C43
		db C44, 	.8
		db D41, 	D42;10
		db D43, 	D44
		db .8,  	D41;11
		db D42, 	D43
		db D44, 	.8
		db D41, 	D42;12
		db D43, 	D44
		db .8,  	D41;13
		db D42, 	D43
		db D44, 	.8
		db E41, 	E42;14
		db E43, 	E44
		db .16, 		D41;15
		db D42, 	D43
		db D44, 	.16
		db C41, 	C42;16
		db C43, 	C44
		db .24, 	0x00
		db 0x00,	0x00
		db 0x00,	0x00

;Super Mario Bros Overworld Theme Song
MarioSong
		db E51, 	E52
		db E53, 	E54
		db .2, 		E51
		db E52, 	E53
		db E54, 	.2
		db P1, 		P1
		db E51, 	E52
		db E53, 	E54
		db .2, 		P1
		db P1, 		C51
		db C52, 	C53
		db C54, 	.2
		db E51, 	E52
		db E53, 	E54
		db .2, 		P1
		db P1, 		B41
		db B42, 	B43
		db B44, 	.2
		db P2, 		P2
		db G41, 	G42
		db G43, 	G44
		db .2,  	P3
		db P3,		C51
		db C52,		C53
		db C54,		.2
		db P2, 		P2
		db G41, 	G42
		db G43, 	G44
		db .2, 		P2
		db P2, 		E41
		db E42, 	E43
		db E44, 	.2
		db P2, 		P2
		db A41, 	A42
		db A43, 	A44
		db .2, 		P1_2
		db P1_2, 	B41
		db B42, 	B43
		db B44, 	.2
		db P3_2, 	P3_2
		db Bb41, 	Bb42
		db Bb43, 	Bb44
		db .2, 		A41
		db A42, 	A43
		db A44, 	.2
		db P1, 		P1
		db G41, 	G42
		db G43, 	G44
		db .2, 		E51
		db E52, 	E53
		db E54, 	.2
		db G51, 	G52
		db G53, 	G54
		db .2, 		A51
		db A52, 	A53
		db A54, 	.2
		db P1, 		P1
		db F51, 	F52
		db F53, 	F54
		db .2, 		G51
		db G52, 	G53
		db G54, 	.2
		db P1, 		P1
		db E51, 	E52
		db E53, 	E54
		db .2, 		P1
		db P1, 		C51
		db C52, 	C53
		db C54, 	.2
		db D51, 	D52
		db D53, 	D54
		db .2, 		Bb41
		db Bb42, 	Bb43
		db Bb44, 	.2
		db P2, 		P2
		db C51, 	C52
		db C53, 	C54
		db .2, 		P2
		db P2, 		G41
		db G42,		G43
		db G44, 	.2
		db P2, 		P2
		db E41, 	E42
		db E43, 	E44
		db .2, 		P2
		db P2, 		A41
		db A42, 	A43
		db A44, 	.2
		db P1, 		P1
		db B41, 	B42
		db B43, 	B44
		db .2, 		P1
		db P1,	 	Bb41 
		db Bb42,	Bb43 
		db Bb44,	.2 
		db A41,	 	A42 
		db A43,	 	A44 
		db .2,		B41 
		db B42,	 	B43 
		db B44,	 	.4 
		db B41,	 	B42 
		db B43,	 	B44 
		db .2,		G51 
		db G52,	 	G53 
		db G54,	 	.2 
		db A51,	 	A52 
		db A53,	 	A54 
		db .2,		P1 
		db P1,	 	F51 
		db F52,	 	F53 
		db F54,	 	.2 
		db G51,	 	G52 
		db G53,	 	G54 
		db .2,		P1 
		db P1,	 	E51 
		db E52,	 	E53 
		db E54,	 	.2 
		db P1,	 	P1 
		db C51,	 	C52 
		db C53,	 	C54 
		db .2,		D51 
		db D52,	 	D53 
		db D54,	 	.2 
		db B41,	 	B42 
		db B43,	 	B44 
		db .2,		C31 
		db C32,	 	C33 
		db C34,	 	.4 
		db 0x00,	0x00
		db 0x00,	0x00
		db 0x00

;A sweeping frequency from 146Hz to 1kHz
SweepingFrequencySong
		db D31,  D32
		db D33,  D34
		db .1,   Eb31
		db Eb32, Eb33
		db Eb34, .1
		db E31,  E32
		db E33,  E34
		db .1,   F31
		db F32,  F33
		db F34,  .1
		db Gb31, Gb32
		db Gb33, Gb34
		db .1,   G31
		db G32,  G33
		db G34,  .1
		db Ab31, Ab32
		db Ab33, Ab34
		db .1,   A31
		db A32,  A33
		db A34,  .1
		db Bb31, Bb32
		db Bb33, Bb34
		db .1,   B31
		db B32,  B33
		db B34,  .1
		db C41,  C42
		db C43,  C44
		db .1,   Db41
		db Db42, Db43
		db Db44, .1
		db D41,  D42
		db D43,  D44
		db .1,   Eb41
		db Eb42, Eb43
		db Eb44, .1
		db E41,  E42
		db E43,  E44
		db .1,   F41
		db F42,  F43
		db F44,  .1
		db Gb41, Gb42
		db Gb43, Gb44
		db .1,   G41
		db G42,  G43
		db G44,  .1
		db Ab41, Ab42
		db Ab43, Ab44
		db .1,   A41
		db A42,  A43
		db A44,  .1
		db Bb41, Bb42
		db Bb43, Bb44
		db .1,   B41
		db B42,  B43
		db B44,  .1
		db C51,  C52
		db C53,  C54
		db .1,   Db51
		db Db52, Db53
		db Db54, .1
		db D51,  D52
		db D53,  D54
		db .1,   Eb51
		db Eb52, Eb53
		db Eb54, .1
		db E51,  E52
		db E53,  E54
		db .1,   F51
		db F52,  F53
		db F54,  .1
		db Gb51, Gb52
		db Gb53, Gb54
		db .1,   G51
		db G52,  G53
		db G54,  .1
		db Ab51, Ab52
		db Ab53, Ab54
		db .1,   A51
		db A52,  A53
		db A54, .1
		db Bb51, Bb52
		db Bb53, Bb54
		db .1,   B51
		db B52,  B53
		db B54,  .1
		db 0x00, 0x00
		db 0x00, 0x00
		db 0x00

;Beethoven's Theme from Symphony No.9: Ode to Joy 
OdeToJoySong
		db E41, 	E42;1
		db E43, 	E44
		db P1,	 	E41;2
		db E42, 	E43
		db E44, 	P1
		db F41, 	F42;3
		db F43, 	F44
		db P1,	 	G41;4
		db G42, 	G43
		db G44, 	P1
		db G41, 	G42;5
		db G43, 	G44
		db P1,	 	F41;6
		db F42, 	F43
		db F44, 	P1
		db E41, 	E42;7
		db E43, 	E44
		db P1,	 	D41;8
		db D42, 	D43
		db D44, 	P1
		db C41, 	C42;9
		db C43, 	C44
		db P1,	 	C41;10
		db C42, 	C43
		db C44, 	P1
		db D41, 	D42;11
		db D43, 	D44
		db P1,	 	E41
		db E42, 	E43;12
		db E44, 	P1
		db E41, 	E42;13
		db E43, 	E44
		db P3_2, 	D41;14
		db D42, 	D43
		db D44, 	P1_2
		db D41, 	D42;15
		db D43, 	D44
		db P2,	 	E31;16
		db E32, 	E33
		db E34, 	P1
		db E31, 	E32;17
		db E33, 	E34
		db P1,	 	F31;18
		db F32, 	F33
		db F34, 	P1
		db G31, 	G32;19
		db G33, 	G34
		db P1,	 	G31;20
		db G32, 	G33
		db G34, 	P1
		db F31, 	F32;21
		db F33, 	F34
		db P1,	 	E31;22
		db E32, 	E33
		db E34, 	P1
		db D31, 	D32;23
		db D33, 	D34
		db P1,	 	C31;24
		db C32, 	C33
		db C34, 	P1
		db C31, 	C32;25
		db C33, 	C34
		db P1,	 	D31;26
		db D32, 	D33
		db D34, 	P1
		db E31, 	E32;27
		db E33, 	E34
		db P1,	 	D31;28
		db D32, 	D33
		db D34, 	P3_2
		db C31, 	C32;29
		db C33, 	C34
		db P1_2, 	C31;30
		db C32, 	C33
		db C34, 	P2
		db D41, 	D42;31
		db D43, 	D44
		db P1,	 	D41;32
		db D42, 	D43
		db D44, 	P1
		db E41, 	E42;33
		db E43, 	E44
		db P1,	 	C41;34
		db C42, 	C43
		db C44, 	P1
		db D41, 	D42;35
		db D43, 	D44
		db P1,	 	E41;36
		db E42, 	E43
		db E44, 	P1_2
		db F41, 	F42;37
		db F43, 	F44
		db P1_2, 	E41;38
		db E42, 	E43
		db E44, 	P1
		db C41, 	C42;39
		db C43, 	C44
		db P1,	 	D41;40
		db D42, 	D43
		db D44, 	P1
		db E41, 	E42;41
		db E43, 	E44
		db P1_2, 	F41;42
		db F42, 	F43
		db F44, 	P1_2
		db E41, 	E42;43
		db E43, 	E44
		db P1,	 	D41;44
		db D42, 	D43
		db D44, 	P1
		db C41, 	C42;45
		db C43, 	C44
		db P1,	 	D41;46
		db D42, 	D43
		db D44, 	P1
		db G31,		G32;47
		db G33,		G34
		db P2,	 	E31;49
		db E32,	 	E33
		db E34,	 	P1
		db E31,	 	E32;50
		db E33,	 	E34
		db P1,	 	F31;51
		db F32,	 	F33
		db F34,	 	P1
		db G31,	 	G32;52
		db G33,		G34
		db P1,	 	G31;53
		db G32,	 	G33
		db G34,	 	P1
		db F31,	 	F32;54
		db F33,	 	F34
		db P1,	 	E31;55
		db E32,	 	E33
		db E34,	 	P1
		db D31,	 	D32;56
		db D33,	 	D34
		db P1,	 	C31;57
		db C32,	 	C33
		db C34,	 	P1
		db C31,	 	C32;58
		db C33,	 	C34
		db P1,	 	D31;59
		db D32,	 	D33
		db D34,	 	P1
		db E31,	 	E32;60
		db E33,	 	E34
		db P1,	 	D31;61
		db D32,	 	D33
		db D34,	 	P3_2
		db C31,	 	C32;62
		db C33,	 	C34
		db P1_2, 	C31;63
		db C32,	 	C33
		db C34,	 	P4
		db 0x00, 	0x00
		db 0x00, 	0x00
		db 0x00

ScanKeys_Table
		db B'11101110' ;Test 0' key, top row rightmost key
		db B'11101101' ;Test 1' key
		db B'11101011' ;Test 2' key
		db B'11100111' ;Test 3' key
		db B'11011110' ;Test 4' key, second row rightmost key
		db B'11011101' ;Test 5' key
		db B'11011011' ;Test 6' key
		db B'11010111' ;Test 7' key
		db B'10111110' ;Test 8' key, third row rightmost key
		db B'10111101' ;Test 9' key
		db B'10111011' ;Test A' key
		db B'10110111' ;Test B' key
		db B'01111110' ;Test C' key, bottom row rightmost key
		db B'01111101' ;Test D' key
		db B'01111011' ;Test E' key
		db B'01110111' ;Test F' key
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Mainline program ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Mainline
		;PORTD[3:0] is Rows (output)
		;PORTB[3:0] is Cols (input)
		call  	Initial             ;Initialize everything
		call	InitLCD

		movlw	0x80
		rcall	SetCursor

		movlw	high	Task1
		movwf	TBLPTRH
		movlw	low	Task1
		movwf	TBLPTRL
		call	DisplayC

		rcall 	Delay_10ms

		movlw	high	Task2
		movwf	TBLPTRH
		movlw	low	Task2
		movwf	TBLPTRL
		call	DisplayC

		rcall 	Delay_10ms

FirstMenuScan
		call	Debounce
		call	Buzz
		
		movf	KEYCODE, W
		sublw	.3
		bz		Key_Functions
		
		movf	KEYCODE, W
		sublw	.2
		
		tstfsz	WREG
		bra		FirstMenuScan
		goto	Menu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Initial subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine performs all initializations of variables and registers.
Initial
		movlw   0x5C				;0x3C=1MHz, 0x4C=2MHz, 0x5C=4MHz, 0x6C=8MHz, 0x7C=16MHz
		movwf	OSCCON				;set internal oscillator frequency to 4 MHz

		movlb	0x0f				;Set BSR to 0x0f since ANSELx registers are not in the Access Bank
		
		bsf		RCON, IPEN
		;bsf		INTCON, GIEH
		;enable timer 1
		bsf		T1GCON, TMR1GE
		;enable timer 3
		bsf		T3GCON, TMR3GE
		;enable timer 5
		bsf		T5GCON, TMR5GE

		clrf	PORTD				;Initialize PORTD by clearing output data latches
		clrf	PORTE				;Initialize PORTE by clearing output data latches

		clrf	ANSELD				;Configure PORTD as digital port
		clrf	ANSELE				;Configure PORTE as digital port
		clrf	TRISD				;Set PORTD as output port
		clrf	TRISE				;Set PORTE as as output port

		clrf	ANSELB				;Configure PORTB as digital port
		clrf	ANSELC				;Configure PORTC as digital port
		bcf		INTCON2, 7			;Enable PORTB's internal 20kOhm pull-up resistors

		movlw	B'00001111'
		movwf	TRISB				;Set PORTB[3:0] as input port
		
		movlw	B'00000011'
		movwf	TRISC				;Set PORTC[1:0] as input port

		movlb	0					;Set BSR to 0

		clrf	Line

		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; InitLCD subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine initializes the LCD for writing to the screen.
InitLCD
		call 	Delay_100ms			;Wait for the LCD to power on
		bcf		PORTE, 0			;Prepare to send commands to the LCD
		movlw	high LCDstr
		movwf	TBLPTRH
		movlw	low	LCDstr
		movwf	TBLPTRL
		tblrd*
L1
		bsf	PORTE,1
		movff	TABLAT, PORTD		;Send byte to LCD
		bcf	PORTE, 1
		call	Delay_10ms			;Wait 10ms before sending another so it can process it
		tblrd+*
		movf	TABLAT, F
		bnz	L1
		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Key Functions v2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For Task IV
Key_Functions	
		rcall	ClearBot	;Initialize LCD cursor and display
		rcall	GotoTop
WaitKey_Functions
		call	AnyKey					;Wait for key to be released before executing subroutines
		bnz		WaitKey_Functions

Key_FunctionsLoop
		rcall	CheckEnter				;Check if enter is pressed
		call	AnyKey					;Check if any keys are pressed
		bz		Key_FunctionsLoop
		call	ScanKeys				;Check for keystroke
		bnz		Key_FunctionsLoop		;If no key detected, try again
		movf	KEYCODE, W
		movwf	OLDKEYCODE				;Copy to OLDKEYCODE for debouncing
		call	Delay_10ms				;Debounce the keys with a 20ms delay
		call	Delay_10ms
		call	ScanKeys
		movf	KEYCODE, W
		subwf	OLDKEYCODE, W			;Check if same keystroke
		bnz		Key_FunctionsLoop		;If different keys, repeat
		rcall	Buzz					;Buzz every time a key is pressed
		btfsc	PORTC, 0				;Check shift and lookup ascii codes
		rcall	LookupASCII
		btfss	PORTC, 0
		rcall	LookupShiftASCII
		rcall	DisplayPressedKey		;Show key and increment counters
CheckCharDone
		call	AnyKey					;Wait for key to be released before scanning again
		bnz		CheckCharDone
		bra		Key_FunctionsLoop

LookupShiftASCII
		movlw	low SHIFT_KEY
		movwf 	TBLPTRL
		movlw 	high SHIFT_KEY
		movwf 	TBLPTRH

		movf 	KEYCODE, W
		addwf 	TBLPTRL, F
		movlw	0x00
		addwfc 	TBLPTRH, F
		tblrd*						;Read table location offset by WREG
		movff 	TABLAT, KeyToShow	;Save ASCII code to KeyToShow
		return

LookupASCII
		movlw	low KEY_ASCII
		movwf 	TBLPTRL
		movlw 	high KEY_ASCII
		movwf 	TBLPTRH

		movf 	KEYCODE, W
		addwf 	TBLPTRL, F
		movlw	0x00
		addwfc 	TBLPTRH, F
		tblrd*						;Read table location offset by WREG
		movff 	TABLAT, KeyToShow	;Save ASCII code to KeyToShow
		return

CheckEnter
		btfsc	PORTC, 1			;Check enter key pressed
		bra		CheckEnterDone
		call	SwitchRow
WaitNoEnter						;Wait until enter is no longer pressed
		rcall	Delay_10ms
		btfss	PORTC, 1
		bra		WaitNoEnter
CheckEnterDone
		return

ClearTop							;Clears the LCD's top row
		movlw	high	BlankTop
		movwf	TBLPTRH
		movlw	low	BlankTop
		movwf	TBLPTRL
		rcall	DisplayC
		return

ClearBot							;Clears the LCD's bottom row
		movlw	high	BlankBot
		movwf	TBLPTRH
		movlw	low	BlankBot
		movwf	TBLPTRL
		rcall	DisplayC
		return

Debounce
		call	AnyKey				;Wait for a key to be pressed
		bz		Debounce
		call	ScanKeys			;Find its keycode
		movf	KEYCODE, W
		movwf	OLDKEYCODE
		call	Delay_10ms			;Debounce by waiting 20ms and checking again
		call	Delay_10ms
		call	ScanKeys
		movf	KEYCODE, W
		subwf	OLDKEYCODE, W		;If the key is the same, return
		bnz		Debounce
		return

SetCursor							;Sends WREG to the LCD as a command
		bcf	PORTE, 0
		bsf	PORTE, 1
		movwf	PORTD
		bcf	PORTE, 1
		clrf	Char				;Clear Char counter
		rcall	Delay_10ms
		return

GotoBot
		rcall	ClearBot			;Clear the bottom row by sending 16 spaces
		movlw	0xC0
		rcall	SetCursor			;Set the cursor to the bottom
		rcall	Delay_10ms
		return

GotoTop
		rcall	ClearTop			;Clear the top row by sending 16 spaces
		movlw	0x80
		rcall	SetCursor			;Set the cursor to the top
		rcall	Delay_10ms
		return

DisplayPressedKey					;Displays a character on the LCD and wraps around the row if needed
		movlw	.16
		subwf	Char, W
		bnz		ExitDisplayPressedKey
		call	SwitchRow
ExitDisplayPressedKey
		rcall	DisplayChar
		incf	Char, F
		return

SwitchRow							;Clears the new row and moves the cursor there
		btfss	Line, 0
		call	GotoBot
		btfsc	Line, 0
		call	GotoTop
		incf	Line, F
		clrf	Char
		return

;Generates a buzz for 50ms
Buzz
		movlw 	.50
		movwf	R0
LoopBuzz
		btg		PORTC, RC2 ;Buzz
		rcall 	Delay_1ms
		decf	R0, F
		bnz		LoopBuzz
		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Menu Subroutine;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The menu for Task V: loops the song menus and plays a song when a key is pressed
Menu
		;rcall	Menu1
		clrf	MenuNum
MenuWait							;wait for the key to be released before scanning again
		rcall	AnyKey
		bnz		MenuWait
MenuLoop
		rcall	NextMenu
		rcall	Debounce3s
		rcall	SelectSong
		bra		MenuLoop

Debounce3s
		call	AnyKey3s			;Wait for a key to be pressed or 3s to pass
Debounce3sLoop
		call	ScanKeys			;Find its keycode
		movf	KEYCODE, W
		movwf	OLDKEYCODE
		call	Delay_10ms			;Debounce by waiting 20ms and checking again
		call	Delay_10ms
		call	ScanKeys
		movf	KEYCODE, W
		subwf	OLDKEYCODE, W		;If the key is the same, return
		bnz		Debounce3sLoop
		return

AnyKey3s
		movlw	.10
		movlw	R0
AnyKeyLoop0
       	movlw	.8
		movwf	R1
AnyKeyLoop1								;outer for-loop
		movlw	.125
		movwf	R2
AnyKeyLoop2								;inner for-loop
		rcall	AnyKey
		bnz		AnyKey3sDone
		decf	R2, F
		bnz		AnyKeyLoop2
		decf	R1, F
		bnz		AnyKeyLoop1
		decf	R0, F
		bnz		AnyKeyLoop0
AnyKey3sDone
		return

;Increments the menu counter mod 4
IncrMenu
		incf	MenuNum, F
		movlw	.4
		cpfslt	MenuNum
		clrf	MenuNum
		return

;Displays the next menu according to MenuNum
NextMenu
		movlw	.0
		cpfseq	MenuNum
		bra		CheckMenu1
		rcall	Menu1
		bra		ExitNextMenu
CheckMenu1
		movlw	.1
		cpfseq	MenuNum
		bra		CheckMenu2
		rcall	Menu2
		bra		ExitNextMenu
CheckMenu2
		movlw	.2
		cpfseq	MenuNum
		bra		CheckMenu3
		rcall	Menu3
		bra		ExitNextMenu
CheckMenu3
		movlw	.3
		cpfseq	MenuNum
		bra		ExitNextMenu
		rcall	Menu4	
ExitNextMenu
		return

;Plays the song corresponding to the keys 1-4
SelectSong
		movlw	.3
		cpfseq	KEYCODE
		bra		CheckMario
		call	HotCrossBuns
CheckMario
		movlw	.2
		cpfseq	KEYCODE
		bra		CheckSweep
		call	MarioBros
CheckSweep
		movlw	.1
		cpfseq	KEYCODE
		bra		CheckOde
		call	SweepingFrequency
CheckOde
		movlw	.7
		cpfseq	KEYCODE
		bra		SelectSongExit
		call	OdeToJoy
SelectSongExit
		;call	RotateMenu
		return

Menu1
		;Display song 1
		movlw	high	Song1T
		movwf	TBLPTRH
		movlw	low	Song1T
		movwf	TBLPTRL
		call	DisplayC
		movlw	high	Song1B
		movwf	TBLPTRH
		movlw	low	Song1B
		movwf	TBLPTRL
		rcall	DisplayC
		rcall	IncrMenu
		return

Menu2
		;Display song 2
		movlw	high	Song2T
		movwf	TBLPTRH
		movlw	low	Song2T
		movwf	TBLPTRL
		call	DisplayC
		movlw	high	Song2B
		movwf	TBLPTRH
		movlw	low	Song2B
		movwf	TBLPTRL
		rcall	DisplayC
		rcall	IncrMenu
		return

Menu3
		;Display song 2
		movlw	high	Song3T
		movwf	TBLPTRH
		movlw	low	Song3T
		movwf	TBLPTRL
		call	DisplayC
		movlw	high	Song3B
		movwf	TBLPTRH
		movlw	low	Song3B
		movwf	TBLPTRL
		rcall	DisplayC
		rcall	IncrMenu
		return

Menu4
		;Display song 4
		movlw	high	Song4T
		movwf	TBLPTRH
		movlw	low	Song4T
		movwf	TBLPTRL
		call	DisplayC
		movlw	high	Song4B
		movwf	TBLPTRH
		movlw	low	Song4B
		movwf	TBLPTRL
		rcall	DisplayC
		rcall	IncrMenu
		return

;Plays a note described by DelayNote&DelayToggle NumRepeatNote times
PlayNote
		movff DelayNoteH, R0
		movff DelayNoteL, R1
		movff NumRepeatNote, R4
PlayNoteTiming
		movff DelayNoteH, R0
		movff DelayNoteL, R1
PlayNoteLoopFreq
		btg PORTC, 3		    ;toggle RC3
		movff	DelayToggleH, R2    ;2
		movff	DelayToggleL, R3    ;2
		
PlayNoteLoopDelay
		tstfsz  R3		    ;1/2
		bra     TestR2		    ;2 1/2
		bra     TestedR3	    ;2 1/2
TestR2
		tstfsz  R2		    ;3
		bra     TestR1   ;5 R2 and R3 are 0, so
		bra     TestedR2	    ;5
TestedR3
		nop			    ;3 1/2
		nop			    ;4 1/2
		bc	TestedR2	    ;5
TestedR2
		movf    R3, F		    ;6 Test lo byte
		btfsc   STATUS, Z	    ;6 1/2 Skip if not zero
		decf    R2, F		    ;7 1/2 Decrement hi byte
		decf    R3, F		    ;7 1/2 Decrement lo byte
		bnz 	PlayNoteLoopDelay	    ;8 LoopDelay is 5 instructions cycles + 5 more in Delay_5uS -> 10uS per LoopDelay
TestR1
		movf    R1, F    ; Test lo byte
		btfsc   STATUS, Z  ; Skip if not zero
		decf    R0, F    ; Decrement hi byte
		decf    R1, F    ; Decrement lo byte
		bnz PlayNoteLoopFreq
		decf R4, F
		bnz PlayNoteTiming
		return
						;Return once the DelayNote counter reaches 0

;Plays a song stored in data tables with the format note[2], delay in 1/16ths
PlaySong
		call	Delay_1_16
		clrf	NumZeros
		movlw	.0

		;Read the first 2 bytes and put into DelayNote
		tblrd*+
		movf	TABLAT, F
		cpfsgt	TABLAT
		incf	NumZeros, F
		movff 	TABLAT, DelayNoteH

		tblrd*+
		movf	TABLAT, F
		cpfsgt	TABLAT
		incf	NumZeros, F
		movff 	TABLAT, DelayNoteL

PlaySongDelay
		movff	DelayNoteH, WREG
		subwf	DelayNoteL, W		;Check if both are equal
		bnz		PlaySongContinue
		tstfsz	NumZeros				
		bra		PlaySongContinue		;Continue reading if 0
		bra		PlaySongRunDelay		;If 2 identical values read in a row, delay for that time
PlaySongRunDelay
		rcall	DelaySong
		bra		PlaySong
PlaySongContinue
		
		;Read the next 2 bytes and put it into DelayToggle
		tblrd*+
		movf	TABLAT, F
		cpfsgt	TABLAT
		incf	NumZeros, F
		movff 	TABLAT, DelayToggleH

		tblrd*+
		movf	TABLAT, F
		cpfsgt	TABLAT
		incf	NumZeros, F
		movff 	TABLAT, DelayToggleL

		;The number of times to repeat the note (125ms each time)
		tblrd*+
		movf	TABLAT, F
		cpfsgt	TABLAT
		incf	NumZeros, F
		movff	TABLAT, NumRepeatNote

		;Check for the exit code, which is 5 zeros
		movlw	.5
		subwf	NumZeros, W
		bz		DonePlay
		rcall	PlayNote
		bra		PlaySong
DonePlay
		return
		
;Delay for the time stored in DelayNoteL=DelayNoteH
DelaySong
		rcall	Delay_1_16
		decf	DelayNoteL, F
		bnz		DelaySong
		return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DisplayC subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine transfers the data in TBLPTR to the LCD
DisplayC
		bcf	PORTE, 0		;RS=0 for sending commands
		bsf	PORTE, 1		;Raise E
		tblrd*+
		movff	TABLAT, PORTD
		bcf	PORTE, 1
		call	Delay_40us
		bsf	PORTE, 0
DisplayCLoop
		tblrd*+
		movf	TABLAT, F
		bz	Done
		bsf	PORTE, 1
		movff	TABLAT, PORTD
		bcf	PORTE, 1
		rcall	Delay_40us
		bra	DisplayCLoop
Done
		return

;Sends a single character to the LCD
DisplayChar
		bsf 	PORTE, 0 			;RS=1 for sending data
 		bsf 	PORTE, 1 			;Raise E
		movff	KeyToShow, PORTD	;Set WREG to be the value chosen by the offest of KEYCODE
		bcf 	PORTE, 1 			;Drop E
		rcall	Delay_40us			;wait 40us for LCD to process data
		return

AnyKey
		clrf 	PORTD 				;Drive 4 rows low
		movlw 	B'00001111'			;Load WREG with expected value if none pressed
		xorwf 	PORTB,W 			;WREG=B'xxxx0000 if no key is pressed
		andlw 	B'00001111'			;Force upper 4 don't care bits to 0
		return						;Return with Z = 1 if no key is pressed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Scankey subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The KEYCODE is a variable defined in data memory for storing the key code.
; If a legitimate key stroke was found, it is returned in KEYCODE and with Z=1; otherwise Z=0.
; The 16 keys are organized in 4X4 format as [3,2,1,0], [7,6,5,4], [B,A,9,8], [F,E,D,C]
; The upper 4 bits are the output row scanning bit pattern at PORTD<3:0>
; The lower 4 bits are the expected input bit pattern at PORTB<3:0> for a pressed key
ScanKeys
		clrf	KEYCODE 			;Start by checking the 0" key
		movlw	high ScanKeys_Table		;Load higher byte address of ScanKeys_Table to WREG
		movwf	TBLPTRH 			;Load higher byte address of ScanKeys_Table to TBLPTRH
		movlw	low ScanKeys_Table		;Load lower byte address of ScanKeys_Table to WREG
		movwf	TBLPTRL 			;Load lower byte address of ScanKeys_Table to TBLPTRL
ScanKey_1
		tblrd*+ 				;Get the table entry and increment table pointer
		swapf	TABLAT, W 			;Read and swap the table data into W
		movwf	PORTD 				;RD<3:0> set to the row scanning testing value
		swapf	WREG, W 			;Swap expected input bit pattern to lower 4 bits
		xorwf	PORTB, W 			;Compare RB<3:0> with expected bit pattern
		andlw	B'00001111'			;Z=1 if RB<3:0> match WREG<3:0>
		btfsc	STATUS, Z 			;Z=0, no match, try the next key switch
		bra		ScanKey_DONE 		;Z=1, a match is found
		tblrd*+ 				;increment pointer by 1, db bytes are stored in 16 bits
		incf	KEYCODE, F 			;Try next key
		btfss	KEYCODE, 4 			;Stop searching with Z=0 when all 16 keys have been checked
		bra		ScanKey_1 		;Start another search
ScanKey_DONE
		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Delay_1ms subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This subroutine is a 1ms delay loop generated  by a nested for-loop
Delay_1ms
		movlw	.250
		movwf	R1
Loop7								;inner for-loop
		nop
		nop
		nop
		decf	R1, F
		bnz	Loop7
		return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Delay_10ms subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This subroutine is a 10ms delay loop generated  by a nested for-loop
Delay_10ms
       	movlw	.8
		movwf	R0
Loop1								;outer for-loop
		movlw	.250
		movwf	R1
Loop2								;inner for-loop
		nop
		nop
		decf	R1, F
		bnz	Loop2
		decf	R0, F
		bnz	Loop1
		return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Delay_40us subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Pause at least 40 microseconds or 40/1 = 40 clock cycles with 4 MHZ clock.
Delay_40us
		movlw 	.50 ;Each loop takes 3 cycles for a total of 153 cycles
		movwf	COUNT
T401
		decf	COUNT,F
		bnz 	T401
		return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Delay_100ms subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This subroutine is a 100ms delay loop generated by Delay_10ms
Delay_100ms
		movlw	.10
		movwf	COUNT
L4
		call	Delay_10ms
		decf	COUNT, F
		bnz L4
		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Delay_1_16 subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This subroutine is a 6.25ms delay loop generated by a nested for-loop
Delay_1_16;debugging
		movff	D1_16H,R0
Loop8								;outer for-loop
		movff	D1_16L,R1
Loop9								;inner for-loop
		nop
		nop
		decf	R1, F
		bnz	Loop9
		decf	R0, F
		bnz	Loop8
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		;btg		PORTC, RC2
		return

;Set Delay_1_16 to the normal length
SetBPM60
		movlw	.200
		movwf	D1_16H
		movlw	.62
		movwf	D1_16L
		;movlw	.67
		;movwf	DelayNum
		return

;Adjust Delay_1_16 for fast paced songs
SetBPM200
		movlw	.80
		movwf	D1_16H
		movlw	.30
		movwf	D1_16L
		;movlw	.29
		;movwf	DelayNum
		return

;Generates a frequency from 25kHz to 25Hz
SweepingFrequency
		call	Menu3
		movlw	high	SweepingFrequencySong
		movwf	TBLPTRH
		movlw	low	SweepingFrequencySong
		movwf	TBLPTRL
		call	PlaySong
		movlw	.3
		movwf	MenuNum
		return

;Implemented using data tables and the project handout's table
HotCrossBuns
		call	Menu1
		movlw	high	HotCrossBunsSong
		movwf	TBLPTRH
		movlw	low		HotCrossBunsSong
		movwf	TBLPTRL
		call	PlaySong
		movlw	.1
		movwf	MenuNum
		return

;Beethoven's Ode to Joy
;asm generated using a Java program
OdeToJoy
		call 	SetBPM60
		call	Menu4
		movlw	high OdeToJoySong
		movwf	TBLPTRH
		movlw	low OdeToJoySong
		movwf	TBLPTRL
		call	PlaySong
		movlw	.4
		movwf	MenuNum
		return

;Super Mario Bros Overworld / Main Theme
;asm generated using a Java program
MarioBros
		call 	SetBPM200
		call	Menu2
		movlw	high MarioSong
		movwf	TBLPTRH
		movlw	low	MarioSong
		movwf	TBLPTRL
		call	PlaySong
		movlw	.2
		movwf	MenuNum
		return

;Definitions for each note and delay
P1_8 EQU .1
P1_4 EQU .2
P1_2 EQU .4
P1	 EQU .8
P3_2 EQU .12
P2	 EQU .16
P3	 EQU .24
P4	 EQU .32
A#01 EQU 0x00
A#02 EQU 0x07
A#03 EQU 0x05
A#04 EQU 0x07
A#11 EQU 0x00
A#12 EQU 0x0E
A#13 EQU 0x02
A#14 EQU 0x84
A#21 EQU 0x00
A#22 EQU 0x1E
A#23 EQU 0x01
A#24 EQU 0x42
A#31 EQU 0x00
A#32 EQU 0x3C
A#33 EQU 0x00
A#34 EQU 0xA1
A#41 EQU 0x00
A#42 EQU 0x79
A#43 EQU 0x00
A#44 EQU 0x50
A#51 EQU 0x00
A#52 EQU 0xF3
A#53 EQU 0x00
A#54 EQU 0x28
A#61 EQU 0x01
A#62 EQU 0xE5
A#63 EQU 0x00
A#64 EQU 0x14
A#71 EQU 0x03
A#72 EQU 0xCB
A#73 EQU 0x00
A#74 EQU 0x0A
A#81 EQU 0x07
A#82 EQU 0x97
A#83 EQU 0x00
A#84 EQU 0x05
A01 EQU 0x00
A02 EQU 0x06
A03 EQU 0x05
A04 EQU 0x54
A11 EQU 0x00
A12 EQU 0x0D
A13 EQU 0x02
A14 EQU 0xAA
A21 EQU 0x00
A22 EQU 0x1C
A23 EQU 0x01
A24 EQU 0x55
A31 EQU 0x00
A32 EQU 0x39
A33 EQU 0x00
A34 EQU 0xAA
A41 EQU 0x00
A42 EQU 0x72
A43 EQU 0x00
A44 EQU 0x55
A51 EQU 0x00
A52 EQU 0xE2
A53 EQU 0x00
A54 EQU 0x2B
A61 EQU 0x01
A62 EQU 0xCE
A63 EQU 0x00
A64 EQU 0x15
A71 EQU 0x03
A72 EQU 0x73
A73 EQU 0x00
A74 EQU 0x0B
A81 EQU 0x07
A82 EQU 0x97
A83 EQU 0x00
A84 EQU 0x05
Ab01 EQU 0x00
Ab02 EQU 0x06
Ab03 EQU 0x05
Ab04 EQU 0xA5
Ab11 EQU 0x00
Ab12 EQU 0x0D
Ab13 EQU 0x02
Ab14 EQU 0xD2
Ab21 EQU 0x00
Ab22 EQU 0x1B
Ab23 EQU 0x01
Ab24 EQU 0x69
Ab31 EQU 0x00
Ab32 EQU 0x35
Ab33 EQU 0x00
Ab34 EQU 0xB5
Ab41 EQU 0x00
Ab42 EQU 0x6C
Ab43 EQU 0x00
Ab44 EQU 0x5A
Ab51 EQU 0x00
Ab52 EQU 0xD8
Ab53 EQU 0x00
Ab54 EQU 0x2D
Ab61 EQU 0x01
Ab62 EQU 0xA6
Ab63 EQU 0x00
Ab64 EQU 0x17
Ab71 EQU 0x03
Ab72 EQU 0x73
Ab73 EQU 0x00
Ab74 EQU 0x0B
Ab81 EQU 0x06
Ab82 EQU 0x53
Ab83 EQU 0x00
Ab84 EQU 0x06
B01 EQU 0x00
B02 EQU 0x07
B03 EQU 0x04
B04 EQU 0xBF
B11 EQU 0x00
B12 EQU 0x10
B13 EQU 0x02
B14 EQU 0x5F
B21 EQU 0x00
B22 EQU 0x1F
B23 EQU 0x01
B24 EQU 0x30
B31 EQU 0x00
B32 EQU 0x3F
B33 EQU 0x00
B34 EQU 0x98
B41 EQU 0x00
B42 EQU 0x7F
B43 EQU 0x00
B44 EQU 0x4C
B51 EQU 0x00
B52 EQU 0xFF
B53 EQU 0x00
B54 EQU 0x26
B61 EQU 0x01
B62 EQU 0xFF
B63 EQU 0x00
B64 EQU 0x13
B71 EQU 0x04
B72 EQU 0x37
B73 EQU 0x00
B74 EQU 0x09
B81 EQU 0x07
B82 EQU 0x97
B83 EQU 0x00
B84 EQU 0x05
Bb01 EQU 0x00
Bb02 EQU 0x07
Bb03 EQU 0x05
Bb04 EQU 0x07
Bb11 EQU 0x00
Bb12 EQU 0x0E
Bb13 EQU 0x02
Bb14 EQU 0x84
Bb21 EQU 0x00
Bb22 EQU 0x1E
Bb23 EQU 0x01
Bb24 EQU 0x42
Bb31 EQU 0x00
Bb32 EQU 0x3C
Bb33 EQU 0x00
Bb34 EQU 0xA1
Bb41 EQU 0x00
Bb42 EQU 0x79
Bb43 EQU 0x00
Bb44 EQU 0x50
Bb51 EQU 0x00
Bb52 EQU 0xF3
Bb53 EQU 0x00
Bb54 EQU 0x28
Bb61 EQU 0x01
Bb62 EQU 0xE5
Bb63 EQU 0x00
Bb64 EQU 0x14
Bb71 EQU 0x03
Bb72 EQU 0xCB
Bb73 EQU 0x00
Bb74 EQU 0x0A
Bb81 EQU 0x07
Bb82 EQU 0x97
Bb83 EQU 0x00
Bb84 EQU 0x05
C#01 EQU 0x00
C#02 EQU 0x04
C#03 EQU 0x08
C#04 EQU 0x75
C#11 EQU 0x00
C#12 EQU 0x09
C#13 EQU 0x04
C#14 EQU 0x3A
C#21 EQU 0x00
C#22 EQU 0x11
C#23 EQU 0x02
C#24 EQU 0x1D
C#31 EQU 0x00
C#32 EQU 0x23
C#33 EQU 0x01
C#34 EQU 0x0F
C#41 EQU 0x00
C#42 EQU 0x48
C#43 EQU 0x00
C#44 EQU 0x87
C#51 EQU 0x00
C#52 EQU 0x8F
C#53 EQU 0x00
C#54 EQU 0x44
C#61 EQU 0x01
C#62 EQU 0x1E
C#63 EQU 0x00
C#64 EQU 0x22
C#71 EQU 0x02
C#72 EQU 0x3B
C#73 EQU 0x00
C#74 EQU 0x11
C#81 EQU 0x04
C#82 EQU 0xBF
C#83 EQU 0x00
C#84 EQU 0x08
C01 EQU 0x00
C02 EQU 0x03
C03 EQU 0x08
C04 EQU 0xF6
C11 EQU 0x00
C12 EQU 0x08
C13 EQU 0x04
C14 EQU 0x7B
C21 EQU 0x00
C22 EQU 0x11
C23 EQU 0x02
C24 EQU 0x3D
C31 EQU 0x00
C32 EQU 0x22
C33 EQU 0x01
C34 EQU 0x1F
C41 EQU 0x00
C42 EQU 0x43
C43 EQU 0x00
C44 EQU 0x8F
C51 EQU 0x00
C52 EQU 0x87
C53 EQU 0x00
C54 EQU 0x48
C61 EQU 0x01
C62 EQU 0x0D
C63 EQU 0x00
C64 EQU 0x24
C71 EQU 0x02
C72 EQU 0x1B
C73 EQU 0x00
C74 EQU 0x12
C81 EQU 0x04
C82 EQU 0x37
C83 EQU 0x00
C84 EQU 0x09
D#01 EQU 0x00
D#02 EQU 0x04
D#03 EQU 0x07
D#04 EQU 0x88
D#11 EQU 0x00
D#12 EQU 0x0A
D#13 EQU 0x03
D#14 EQU 0xC4
D#21 EQU 0x00
D#22 EQU 0x14
D#23 EQU 0x01
D#24 EQU 0xE2
D#31 EQU 0x00
D#32 EQU 0x28
D#33 EQU 0x00
D#34 EQU 0xF1
D#41 EQU 0x00
D#42 EQU 0x50
D#43 EQU 0x00
D#44 EQU 0x79
D#51 EQU 0x00
D#52 EQU 0xA1
D#53 EQU 0x00
D#54 EQU 0x3C
D#61 EQU 0x01
D#62 EQU 0x44
D#63 EQU 0x00
D#64 EQU 0x1E
D#71 EQU 0x02
D#72 EQU 0x87
D#73 EQU 0x00
D#74 EQU 0x0F
D#81 EQU 0x04
D#82 EQU 0xBF
D#83 EQU 0x00
D#84 EQU 0x08
D01 EQU 0x00
D02 EQU 0x04
D03 EQU 0x07
D04 EQU 0xFC
D11 EQU 0x00
D12 EQU 0x09
D13 EQU 0x03
D14 EQU 0xFE
D21 EQU 0x00
D22 EQU 0x12
D23 EQU 0x01
D24 EQU 0xFF
D31 EQU 0x00
D32 EQU 0x26
D33 EQU 0x00
D34 EQU 0xFF
D41 EQU 0x00
D42 EQU 0x4C
D43 EQU 0x00
D44 EQU 0x80
D51 EQU 0x00
D52 EQU 0x97
D53 EQU 0x00
D54 EQU 0x40
D61 EQU 0x01
D62 EQU 0x2F
D63 EQU 0x00
D64 EQU 0x20
D71 EQU 0x02
D72 EQU 0x5F
D73 EQU 0x00
D74 EQU 0x10
D81 EQU 0x04
D82 EQU 0xBF
D83 EQU 0x00
D84 EQU 0x08
Db01 EQU 0x00
Db02 EQU 0x04
Db03 EQU 0x08
Db04 EQU 0x75
Db11 EQU 0x00
Db12 EQU 0x09
Db13 EQU 0x04
Db14 EQU 0x3A
Db21 EQU 0x00
Db22 EQU 0x11
Db23 EQU 0x02
Db24 EQU 0x1D
Db31 EQU 0x00
Db32 EQU 0x23
Db33 EQU 0x01
Db34 EQU 0x0F
Db41 EQU 0x00
Db42 EQU 0x48
Db43 EQU 0x00
Db44 EQU 0x87
Db51 EQU 0x00
Db52 EQU 0x8F
Db53 EQU 0x00
Db54 EQU 0x44
Db61 EQU 0x01
Db62 EQU 0x1E
Db63 EQU 0x00
Db64 EQU 0x22
Db71 EQU 0x02
Db72 EQU 0x3B
Db73 EQU 0x00
Db74 EQU 0x11
Db81 EQU 0x04
Db82 EQU 0xBF
Db83 EQU 0x00
Db84 EQU 0x08
E01 EQU 0x00
E02 EQU 0x05
E03 EQU 0x07
E04 EQU 0x1C
E11 EQU 0x00
E12 EQU 0x0A
E13 EQU 0x03
E14 EQU 0x8E
E21 EQU 0x00
E22 EQU 0x14
E23 EQU 0x01
E24 EQU 0xC7
E31 EQU 0x00
E32 EQU 0x2A
E33 EQU 0x00
E34 EQU 0xE4
E41 EQU 0x00
E42 EQU 0x55
E43 EQU 0x00
E44 EQU 0x72
E51 EQU 0x00
E52 EQU 0xAA
E53 EQU 0x00
E54 EQU 0x39
E61 EQU 0x01
E62 EQU 0x5A
E63 EQU 0x00
E64 EQU 0x1C
E71 EQU 0x02
E72 EQU 0xB6
E73 EQU 0x00
E74 EQU 0x0E
E81 EQU 0x05
E82 EQU 0x6C
E83 EQU 0x00
E84 EQU 0x07
Eb01 EQU 0x00
Eb02 EQU 0x04
Eb03 EQU 0x07
Eb04 EQU 0x88
Eb11 EQU 0x00
Eb12 EQU 0x0A
Eb13 EQU 0x03
Eb14 EQU 0xC4
Eb21 EQU 0x00
Eb22 EQU 0x14
Eb23 EQU 0x01
Eb24 EQU 0xE2
Eb31 EQU 0x00
Eb32 EQU 0x28
Eb33 EQU 0x00
Eb34 EQU 0xF1
Eb41 EQU 0x00
Eb42 EQU 0x50
Eb43 EQU 0x00
Eb44 EQU 0x79
Eb51 EQU 0x00
Eb52 EQU 0xA1
Eb53 EQU 0x00
Eb54 EQU 0x3C
Eb61 EQU 0x01
Eb62 EQU 0x44
Eb63 EQU 0x00
Eb64 EQU 0x1E
Eb71 EQU 0x02
Eb72 EQU 0x87
Eb73 EQU 0x00
Eb74 EQU 0x0F
Eb81 EQU 0x04
Eb82 EQU 0xBF
Eb83 EQU 0x00
Eb84 EQU 0x08
F#01 EQU 0x00
F#02 EQU 0x06
F#03 EQU 0x06
F#04 EQU 0x56
F#11 EQU 0x00
F#12 EQU 0x0B
F#13 EQU 0x03
F#14 EQU 0x2B
F#21 EQU 0x00
F#22 EQU 0x18
F#23 EQU 0x01
F#24 EQU 0x95
F#31 EQU 0x00
F#32 EQU 0x30
F#33 EQU 0x00
F#34 EQU 0xCB
F#41 EQU 0x00
F#42 EQU 0x60
F#43 EQU 0x00
F#44 EQU 0x65
F#51 EQU 0x00
F#52 EQU 0xBE
F#53 EQU 0x00
F#54 EQU 0x33
F#61 EQU 0x01
F#62 EQU 0x84
F#63 EQU 0x00
F#64 EQU 0x19
F#71 EQU 0x02
F#72 EQU 0xEB
F#73 EQU 0x00
F#74 EQU 0x0D
F#81 EQU 0x06
F#82 EQU 0x53
F#83 EQU 0x00
F#84 EQU 0x06
F01 EQU 0x00
F02 EQU 0x05
F03 EQU 0x06
F04 EQU 0xB6
F11 EQU 0x00
F12 EQU 0x0B
F13 EQU 0x03
F14 EQU 0x5B
F21 EQU 0x00
F22 EQU 0x16
F23 EQU 0x01
F24 EQU 0xAE
F31 EQU 0x00
F32 EQU 0x2D
F33 EQU 0x00
F34 EQU 0xD7
F41 EQU 0x00
F42 EQU 0x5A
F43 EQU 0x00
F44 EQU 0x6B
F51 EQU 0x00
F52 EQU 0xB3
F53 EQU 0x00
F54 EQU 0x36
F61 EQU 0x01
F62 EQU 0x67
F63 EQU 0x00
F64 EQU 0x1B
F71 EQU 0x02
F72 EQU 0xEB
F73 EQU 0x00
F74 EQU 0x0D
F81 EQU 0x05
F82 EQU 0x6C
F83 EQU 0x00
F84 EQU 0x07
G#01 EQU 0x00
G#02 EQU 0x06
G#03 EQU 0x05
G#04 EQU 0xA5
G#11 EQU 0x00
G#12 EQU 0x0D
G#13 EQU 0x02
G#14 EQU 0xD2
G#21 EQU 0x00
G#22 EQU 0x1B
G#23 EQU 0x01
G#24 EQU 0x69
G#31 EQU 0x00
G#32 EQU 0x35
G#33 EQU 0x00
G#34 EQU 0xB5
G#41 EQU 0x00
G#42 EQU 0x6C
G#43 EQU 0x00
G#44 EQU 0x5A
G#51 EQU 0x00
G#52 EQU 0xD8
G#53 EQU 0x00
G#54 EQU 0x2D
G#61 EQU 0x01
G#62 EQU 0xA6
G#63 EQU 0x00
G#64 EQU 0x17
G#71 EQU 0x03
G#72 EQU 0x73
G#73 EQU 0x00
G#74 EQU 0x0B
G#81 EQU 0x06
G#82 EQU 0x53
G#83 EQU 0x00
G#84 EQU 0x06
G01 EQU 0x00
G02 EQU 0x06
G03 EQU 0x05
G04 EQU 0xFB
G11 EQU 0x00
G12 EQU 0x0C
G13 EQU 0x02
G14 EQU 0xFD
G21 EQU 0x00
G22 EQU 0x19
G23 EQU 0x01
G24 EQU 0x7F
G31 EQU 0x00
G32 EQU 0x32
G33 EQU 0x00
G34 EQU 0xBF
G41 EQU 0x00
G42 EQU 0x65
G43 EQU 0x00
G44 EQU 0x60
G51 EQU 0x00
G52 EQU 0xCA
G53 EQU 0x00
G54 EQU 0x30
G61 EQU 0x01
G62 EQU 0x95
G63 EQU 0x00
G64 EQU 0x18
G71 EQU 0x03
G72 EQU 0x2A
G73 EQU 0x00
G74 EQU 0x0C
G81 EQU 0x06
G82 EQU 0x53
G83 EQU 0x00
G84 EQU 0x06
Gb01 EQU 0x00
Gb02 EQU 0x06
Gb03 EQU 0x06
Gb04 EQU 0x56
Gb11 EQU 0x00
Gb12 EQU 0x0B
Gb13 EQU 0x03
Gb14 EQU 0x2B
Gb21 EQU 0x00
Gb22 EQU 0x18
Gb23 EQU 0x01
Gb24 EQU 0x95
Gb31 EQU 0x00
Gb32 EQU 0x30
Gb33 EQU 0x00
Gb34 EQU 0xCB
Gb41 EQU 0x00
Gb42 EQU 0x60
Gb43 EQU 0x00
Gb44 EQU 0x65
Gb51 EQU 0x00
Gb52 EQU 0xBE
Gb53 EQU 0x00
Gb54 EQU 0x33
Gb61 EQU 0x01
Gb62 EQU 0x84
Gb63 EQU 0x00
Gb64 EQU 0x19
Gb71 EQU 0x02
Gb72 EQU 0xEB
Gb73 EQU 0x00
Gb74 EQU 0x0D
Gb81 EQU 0x06
Gb82 EQU 0x53
Gb83 EQU 0x00
Gb84 EQU 0x06
 
end
