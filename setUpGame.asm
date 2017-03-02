; SoC Design Pong Game
; Aoife McDonagh, 13411348
; Martin Durcan
; Tara Bourke
;
;
;
main: CALL initPaddle		; setup paddle width and position in data memory
CALL initBall				; allow user to specify ball starting position and direction
CALL initWall				; set up the wall
CALL setupTimer				; set up 1sec timer 
END

initPaddle:
XOR R4, R4, R4				; Clear R4 for use in function
SETBR R4, 15	
SHRA R4, 4
SHRL R4, 6					; R4 = 03E0h (paddle at initial location)
XOR R5, R5, R5				; Clear R5 for use in function
SETBR R5, 4					; R5 = 0010h (data memory address for paddle location)
MOVBAMEM @R5, R4			; Move paddle position to data memory 

XOR R4, R4, R4				; Clear R4 for use in function
SETBR R4, 4
SETBR R4, 5
SETBR R4, 6					; R4 = 0070
OR R0, R0, R4				; Moving the paddle location to R0
RET

initBall:
XOR R4, R4, R4				; Clear R4 for use in function
SETBR R4, 7					; Set bit to act as ball location 
XOR R5, R5, R5				; Clear R5 for use in function
SETBR R5, 0
SETBR R5, 4					; R5 = 0011h (data memory address for paddle location)
MOVBAMEM @R5, R4			; Move paddle position to data memory 

XOR R4, R4, R4				; Clear R4 for use in function
SETBR R4, 8
SETBR R4, 9
SETBR R4, 10				; R4 = 0700
OR R0, R0, R4				; Moving the ball's x location to R0

XOR R4, R4, R4				; Clear R4 for use in function
SETBR R4, 12				; R4 = 1000
OR R0, R0, R4				; Moving the ball's y location to R0
RET

initWall:
XOR R4, R4, R4				; Clear R4 for use in function
INV R4, R4					; R4 = FFFFh
XOR R5, R5, R5				; Clear R5 for use in function
SETBR R5, 4
SETBR R5, 3
SETBR R5, 2
SETBR R5, 0					; R5 = 001Dh (memory location of wall)
MOVBAMEM @R5, R4			; Move wall to memory
RET

setupTimer: 
; Setup the LDVAL registers for the timers
XOR R4, R4, R4	; R4 = 0000h
INVBR R4, 15	; R4 = 8000h
SHRA R4, 6		; R4 = FE00h
SETBR R4, 7		; R4 = FE80h
SETBR R4, 1		; R4 = FE82h
MOVRSFR SFR2, R4	; SFR2 = FE82h
MOVRSFR SFR7, R4	; SFR7 = FE82h

XOR R4, R4, R4	; Set R4 back to 0000h
SETBR R4, 11	; R4 = 0800h
INV R4, R4		; R4 = F7FFh
SHRL R4, 5		; R4 = 07BFh
INVBR R4, 15	; R4 = 87BRh
MOVRSFR SFR1, R4	; SFR1 = 87BRh
MOVRSFR SFR6, R4	; SFR6 = 87BRh

; Enabling timers and interrupts
SETBSFR SFR0, 5	; Enabling timer auto-reload
SETBSFR SFR0, 3	; Enabling timer interrupt
SETBSFR SFR0, 0	; Enabling global interrupts
SETBSFR SFR0, 4	; Enabling timer
RET

ISR2:
CALL setupTimer
RETI
