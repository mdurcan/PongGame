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
;CALL setupTimer			; 
END

initPaddle:
XOR R4, R4, R4				; Clear R4 for use in function
SETBR R4, 15	
SHRA R4, 4
SHRL R4, 6					; R4 = 03E0h (paddle at initial location)
XOR R5, R5, R5				; Clear R5 for use in function
SETBR R5, 1
SETBR R5, 2
SETBR R5, 4					; R5 = 0010h (data memory address for paddle location)
MOVBAMEM @R5, R4			; Move paddle position to data memory 
RET

initBall:
XOR R4, R4, R4				; Clear R4 for use in function
MOVSFRR R4, SFR5			; Move inPort value to R4 
SHRL R4, 7					; Shift out the LED value leftover from SFR5
SHLL R4, 7					; Shift the inPort value back to bits 15:8, preparing to move them to R0
MOVRR R0, R4				; Move ball X and Y location to R0
RET

initWall:
XOR R4, R4, R4				; Clear R4 for use in function
INV R4, R4					; R4 = FFFFh
XOR R5, R5, R5				; Clear R5 for use in function
SETBR R5, 4
SHRL R5, 2
SETBR R5, 0					; R5 = 001Dh (memory location of wall)
MOVBAMEM @R5, R4			; Move wall to memory
RET

setupTimer: 
; Enabling timers and interrupts
SETBSFR SFR0, 5	; Enabling timer auto-reload
SETBSFR SFR0, 3	; Enabling timer interrupt
SETBSFR SFR0, 0	; Enabling global interrupts
SETBSFR SFR0, 4	; Enabling timer



RET


