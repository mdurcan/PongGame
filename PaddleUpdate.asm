;paddle update

PaddleUpdate:
	MOVSFRR R5,SFR5				;Import button value
	SHRL R5,8					; shifts over 8 to import button values alone
	CALL CheckRightButton		;Call CheckRightButton function 
	JZ R6,RightButtonPressed	;Jump to RightButtonPressed if zero
	CALL CheckLeftButton		;Call CheckLeftButton function
	JZ R6, LeftButtonPressed	;Jump to LeftButtonPressed if zero
RET
	
RightButtonPressed:
	CALL CheckPaddleAtR			;Call CheckPaddleAtR to check if paddle is at right border
	JZ R6,2						;Jump 2 lines if zero
	CALL ShiftPaddleRight		;Else, Call ShiftPaddleRight
RET
	
	
LeftButtonPressed:
	CALL CheckPaddleAtL			;Call CheckPaddleAtL to check if paddle is at left border
	JZ R6,2						;Jump 2 lines if zero
	CALL ShiftPaddleLeft		;Else, Call ShiftPaddleLeft
RET
	
;FUNCTIONS

; Get Paddle Loc
GetPaddleLoc:
	MOVRR R5, R0			; move data to R5
	SHLL R5, 8				; shift left and
	SHRL R5, 12				; shift right to get Paddle location alone
RET							; returns paddle location to R5

CheckPaddleAtR:
	CALL GetPaddleLoc		;Call GetPaddleLoc for paddle location
	XOR R4,R4,R4			;R4 = 0000h
	ADDI R4,R4,5			;R4 = 0005h
	ADDI R4,R4,6			;R4 = 000Bh
	XOR R6,R4,R5			;R6 = R4 - R5
RET

CheckPaddleAtL:
	CALL GetPaddleLoc		;Call GetPaddleLoc for paddle location
	MOVRR R6,R5				;Move R5 to R6
RET

CheckRightButton:
	XOR R4,R4,R4			;R4 = 0000h
	SETBR R4,0				;R4 = 0001h
	AND R6,R4,R5
	XOR R6,R4,R6			;R6 = R4 - R5
RET

CheckLeftButton:
	XOR R4,R4,R4			;R4 = 0000h
	SETBR R4,1				;R4 = 0002h
	AND R6,R4,R5
	XOR R6,R4,R6			;R6 = R4 - R5
RET

ShiftPaddleRight:
	XOR R4,R4,R4			;R4 = 0000h
	SETBR R4,4				;R4 = 0010h
	MOVAMEMR R5,@R4			;Put value from memory address in R4 to R5
	SHRL R5,1				;Shift value in R5 right by 1
	MOVBAMEM @R4,R5			;Put value in R5 to memory address in R4
RET

ShiftPaddleLeft:
	XOR R4,R4,R4			;R4 = 0000h
	SETBR R4,4				;R4 = 0010h
	MOVAMEMR R5,@R4			;Put value from memory address in R4 to R5
	SHLL R5,1				;Shift value in R5 left by 1
	MOVBAMEM @R4,R5			;Put value in R5 to memory address in R4
RET