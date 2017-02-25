; test for checking if in top left corner

;main to test when its not
Main:
	CALL CheckAtTLCorner ; R6=0001h
END

;main to check when it passes
Main:
	CALL BeforeLBorderLoc	;R1=000Fh
	MOVRR R4,R1				;R4=000Fh
	CALL BeforeWallLoc		;R1=000Ch
	MOVRR R5,R1				;R5=000Ch
	CALL CheckAtTLCorner	;R6=0000h
END

; Check if At Top Left corner
; 	0 if yes and 1 for not
;	XLoc in R4 and YLoc in R5
CheckAtTLCorner:
	PUSH R1 		; PUSH R1 so that it can be used
	XOR R6,R6,R6	; clear R6
	CALL BeforeWallLoc	; makes R1 =000Ch to compare against YLoc
	XOR R6,R1,R5	; Compare both, if th Y Location matchs then zero saved to R6
	CALL BeforeLBorderLoc	; makes 4h to compare with XLoc
	XOR R6,R1,R4	; Compare both, if th X Location matchs then zero saved to R6
	POP R1 			; get back R1
RET					; returns the result to R6

; Get location before wall
;  returns R1=000Ch
BeforeWallLoc:
	XOR R1,R1,R1	;CLEAR R1
	ADDI R1,R1,6	;R1=0006h
	ADDI R1,R1,6	;R1=000Ch
RET

; Get location at left border
;  returns R1=000Fh
BeforeLBorderLoc:
	XOR R1,R1,R1	;CLEAR R1
	ADDI R1,R1,7	;R1=0007h
	SETBR R1,3		;R1=000Fh
RET