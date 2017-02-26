; test get the Y location before wall

;main of test
;	R1=000Ch after being called

Main:
	CALL BeforeWallLoc ;R1 = 000Ch
END

; Get location before wall
;  returns R1=000Ch
BeforeWallLoc:
	XOR R1,R1,R1	;CLEAR R1
	ADDI R1,R1,6	;R1=0006h
	ADDI R1,R1,6	;R1=000Ch
RET