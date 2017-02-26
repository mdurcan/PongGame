; test for 

;main for test
Main:
	ADDI R0,R0,5	;R0= 0005h
	CALL GetAngle ; R5 = 0002h if function works
END

; Get Angle of the Ball
;	00: veritcal, 01: +45 and 10: -45
GetAngle:
	MOVRR R5, R0 	; move data to R5
	SHLL R5, 13		; shift left to get angle and direction
	SHRL R5, 14		; shift right to get angle alone
RET					; returns the angle to R5