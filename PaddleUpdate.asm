;paddle update

PaddleUpdate:
	MOVSFRR R5,SFR5
	CALL CheckRightButton
	JZ R6,RightButtonPressed
	CALL CheckLeftButton
	JZ R6, LeftButtonPressed
	RET
	
	RightButtonPressed:
		CALL CheckPaddleAtR
		JZ R6,2
		CALL ShiftPaddleRight
	RET
	
	
	LeftButtonPressed:
		CALL CheckPaddleAtL
		JZ R6,2
		CALL ShiftPaddleLeft
	RET
	
;FUNCTIONS

; Get Paddle Loc
GetPaddleLoc:
	MOVRR R5, R0			; move data to R5
	SHLL R5, 8				; shift left and
	SHRL R5, 12				; shift right to get Paddle location alone
RET							; returns paddle location to R5

CheckPaddleAtR:
	CALL GetPaddleLoc
	XOR R4,R4,R4
	ADDI R4,R4,5
	ADDI R4,R4,6
	XOR R6,R4,R5
RET

CheckPaddleAtL:
	CALL GetPaddleLoc
	MOVRR R6,R5
RET

CheckRightButton:
	XOR R4,R4,R4
	SETBR R4,0
	XOR R6,R4,R5
RET

CheckLeftButton:
	XOR R4,R4,R4
	SETBR R4,1
	XOR R6,R4,R5
RET

ShiftPaddleRight:
	XOR R4,R4,R4
	SETBR R4,4
	MOVAMEMR R5,@R4
	SHRL R5,1
	MOVBAMEM @R4,R5
RET

ShiftPaddleLeft:
	XOR R4,R4,R4
	SETBR R4,4
	MOVAMEMR R5,@R4
	SHLL R5,1
	MOVBAMEM @R4,R5
RET