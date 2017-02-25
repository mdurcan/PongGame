; test get the X location at left border

;main of test
;	R1=000Fh after being called

Main:
	CALL BeforeLBorderLoc ;R1 = 000Fh
END

; Get location at left border
;  returns R1=000Fh
BeforeLBorderLoc:
	XOR R1,R1,R1	;CLEAR R1
	ADDI R1,R1,7	;R1=0007h
	SETBR R1,3		;R1=000Fh
RET