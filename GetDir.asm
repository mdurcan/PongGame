; test for GetDir

; main for testing
;	R0 is 0005h
;	if func corect =8000h
Main:
	SETBR R0, 0		;R0=0001h
	SETBR R0, 2		; R0= 0005h
	CALL GetDir		; CALL FUNC
END

; Get Direction of the ball
; 	0 for up and 1 for down
GetDir:
	MOVRR R6, R0 	; move data to R6
	SHLL R6, 15		; shift data to the left to get direction on its own
RET					; returns the direction to R6
