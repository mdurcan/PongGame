; Pong Game
;//////////////////////////////////////////////////////
;//////////////   main of BallUpdate    ///////////////
;//////////////////////////////////////////////////////

BallUpdate: 
	CALL GetDir					; gets direction of the ball
	JZ R6 , Up					; if direction = up, jumps to up else cotinues to down
	
	Down:
		CALL GetAngle 			; get angle of ball, Angle in R5
		CALL CheckAngleP45		; checks if ball angle is +45
		JZ R6, DownP45			; if angle = +45
		CALL CheckAngleN45		; check if angle is -45
		JZ R6, DownN45			; if angle = -45
		;else angle =vertical
		DownVertical:			; moving Down vertical
			
			MoveDown:			; move down
				
			RET					
			; end MoveDown
			
			PaddleVertical:		; moves vertical after hitting paddle
				
			; end PaddleVertical
		;end DownVertical
		
		DownP45:				; moving Down at +45
		
			MoveDownP45:		; move down at +45
			
			RET
			; end MoveDownP45
			
			PaddleP45:			; moves at +45 after hitting paddle
				
			; end PaddleP45
		;end DownP45
		
		DownN45:				; moving Down at -45
		
			MoveDownN45:		; move down at -45
			
			RET
			; end MoveDownN45
			
			PaddleP45:			; moves at -45 after hitting paddle
				
			; end PaddleN45
		;end DownP45
	;end of Down
	
	Up:
		CALL GetAngle 		; get angle of ball, Angle in R5
		CALL CheckAngleP45	; checks if ball angle is +45
		JZ R6, UpP45		; if angle = +45
		CALL CheckAngleN45	; check if angle is -45
		JZ R6, UpN45		; if angle = -45
		;else
		UpVertical:			; moving up vertical
			CALL GetYLoc		; get y location in R5
			CALL CheckAtWall	; checks if at wall
			JZ R6, AtWall		; if at wall jumps to AtWall 
			;else 
			MoveUp:				; move up
				MOVAMEMR R6, @R5	; gets the Ball from mem
				MOVBAMEM R7, @R7	; clears the where the ball was
				CALL IncYLoc		; increments and saves YLoc
				MOVBAMEM R6, @R5	; saves ball new location
			RET
			
			AtWall:
				CALL ClrWall		; clear wall
				INVBR R0,0			; invert direction to down
			JZ R7, MoveDown		; jumps to move down
			; end MoveUp
		; end UpVertical
		
		UpP45:				; moveing up at +45
			CALL GetXLoc		; gets x location
			CALL GetYLoc		; gets y location
			CALL CheckAtTLCorner; checks if at top left corner
			JZ R6, AtTLCorner	; if at corner jump to AtTLCorner
			;else
			CALL CheckAtWall	; checks if at wall
			JZ R6, AtWallP45	; if at wall jump to AtWall
			;else
			CALL CheckAtLBorder	; checks if at left border
			JZ R6, AtLBorderP45	; if at left border jump to AtLBorderP45
			;else
			MoveUpP45:			; move up at +45
				MOVAMEMR R6, @R5	; gets the Ball from mem
				MOVBAMEM R7, @R7	; clears the where the ball was
				CALL IncYLoc		; increments and saves YLoc
				CALL IncXLoc		; increment and save XLoc
				SHLL R6,1			; shifts the ball left
				MOVBAMEM R6, @R5	; saves ball new location
			RET	
			
			AtTLCorner:			; at the top left corner
				CALL ClrWall		; clear wall
				INVBR R0,0			; invert direction to down
			JZ R7, MoveDownP45	; jumps to move down at +45
			
			AtWallP45:			; at wall 
				CALL ClrWall		; clear wall
				INVBR R0,0			; invert direction to down
				CALL AngleN45		; changes angle to -45
			JZ R7, MoveDownN45	; jumps to move down at -45
			
			AtLBorderP45:		; at border
				CALL AngleN45		; changes angle to -45
			JZ R7, MoveUpN45	; jumps to move up at -45
			; end MoveUpP45
		; end UpP45
		
		UpN45:					; moving up at -45
			
			MoveUpN45:				; move up at -45
			
			RET
			; end MoveUpN45
		;end UpN45
	; end of Up
;end of BallUpdate


;//////////////////////////////////////////////////////
;///////////////////	Functions	///////////////////
;//////////////////////////////////////////////////////

;//////////////////    Getters   //////////////////////

; Get Direction of the ball
; 	0 for up and 1 for down
GetDir:
	MOVRR R6, R0 			; move data to R6
	SHLL R6, 15				; shift data to the left to get direction on its own
RET							; returns the direction to R6


; Get Angle of the Ball
;	00: veritcal, 01: +45 and 10: -45
GetAngle:
	MOVRR R5, R0 			; move data to R5
	SHLL R5, 13				; shift left to get angle and direction
	SHRL R5, 14				; shift right to get angle alone
RET							; returns the angle to R5

; Get X location of ball, outputs R4
GetXLoc:
	MOVRR R4, R0			; move data to R4
	SHLL R4, 4				; shift left to remove Y location
	SHRL R4, 12				; shift right to get X location alone
RET							; return X location to R4


; Get Y location of ball, outputs R5
GetYLoc:	
	MOVRR R5, R0			; move data to R5
	SHRL R5, 12				; shift right to get Y location alone
RET							; return Y location to R5
	
	
; Get Wall, outputs R4
GetWall:
	XOR R4,R4,R4			; clear R4
	ADDI R4,R4,6  			; R4=0006h
	ADDI R4,R4,7 			; R4=000Dh
	SETBR R4,4				; R4=001Dh where wall is stored
	MOVAMEMR R4, @R4		; moves wall to R4
RET							; returns the wall to R4
	

;//////////////////    Actuator   //////////////////////


; increment X location
IncXLoc:
	PUSH R1
	MOVRR R1,R4				; use R1 to remove old value
	SHLL R1,8				; shifts to location of XLoc in R0
	XOR R0,R0,R1			; clears old value
	INC R4					; increment XLoc
	SHLL R4,8				; shift to Xloc
	ADD R0, R0, R4			; Saves new XLoc value
	SHRL R4,8				; shift back for other functions
	POP R1
RET


; Decrement X location
DecXLoc:
	PUSH R1
	MOVRR R1,R4				; use R1 to remove old value
	SHLL R1,8				; shifts to location of XLoc in R0
	XOR R0,R0,R1			; clears old value
	DEC R4					; Decrement XLoc
	SHLL R4,8				; shift to Xloc
	ADD R0, R0, R4			; Saves new XLoc value
	SHRL R4,8				; shift back for other functions
	POP R1
RET


; increment Y location
IncYLoc:
	PUSH R1
	MOVRR R1,R5				; use R1 to remove old value
	SHLL R1,12				; shifts to location of YLoc in R0
	XOR R0,R0,R1			; clears old value
	INC R5					; increment YLoc
	SHLL R5,12				; shifts to location of YLoc in R0
	ADD R0, R0, R5			; Saves new YLoc value
	SHRL R5,12				; shift back for other functions
	POP R1
RET


; Decrement Y location
DecYLoc:
	PUSH R1
	MOVRR R1,R5				; use R1 to remove old value
	SHLL R1,12				; shifts to location of YLoc in R0
	XOR R0,R0,R1			; clears old value
	DEC R5					; Decrement YLoc
	SHLL R5,12				; shifts to location of YLoc in R0
	ADD R0, R0, R5			; Saves new YLoc value
	SHRL R5,12				; shift back for other functions
	POP R1
RET


; set Angle of Ball to Vertical
;	sets Angle = 00
AngleVertical:
	CLRBR R0,1
	CLRBR R0,2
RET


; set Angle of Ball to +45
;	sets Angle = 01
AngleP45:
	SETBR R0,1
	CLRBR R0,2
RET


; set Angle of Ball to -45
;	sets Angle = 10
AngleN45:
	CLRBR R0,1
	SETBR R0,2
RET


;//////////////////    Func   //////////////////////	
	
; Check that the Angle is +45 (01)
;	if it returns all 0 then its +45. else not +45
; 	Angle should be in R5
CheckAngleP45:
	MOVRR R6, R5			;move into R6, for caculating
	INVBR R6, 0				; invert bit(0) if it was +45(01) then the last two bits be 00
RET							; returns result to R6
	

; Check that the Angle is -45 (10)
;	if it returns all 0 then its -45. else not -45	
; 	Angle should be in R5
CheckAngleN45:
	MOVRR R6, R5			;move into R6, for caculating
	INVBR R6, 1				; invert bit(0) if it was -45(10) then the last two bits be 00
RET							; returns result to R6			


; Check if At Top Left corner
; 	0 if yes and 1 for not
;	XLoc in R4 and YLoc in R5
CheckAtTLCorner:
	PUSH R1 				; PUSH R1 so that it can be used
	XOR R6,R6,R6			; clear R6
	CALL BeforeWallLoc		; makes R1 =000Ch to compare against YLoc
	XOR R6,R1,R5			; Compare both, if th Y Location matchs then zero saved to R6
	CALL BeforeLBorderLoc	; makes 4h to compare with XLoc
	XOR R6,R1,R4			; Compare both, if th X Location matchs then zero saved to R6
	POP R1 					; get back R1
RET							; returns the result to R6


; Check if At Top right corner
; 	0 if yes and 1 for not
;	XLoc in R4 and YLoc in R5
CheckAtTRCorner:
	PUSH R1 				; PUSH R1 so that it can be used
	MOVRR R6,R4				; XLoc will be zero if at top right corner
	CALL BeforeWallLoc   	; Makes R1 =000Ch to compare against YLoc
	XOR R6,R1,R5			; Compare both, if th Y Location matchs then zero saved to R6
	POP R1 					; get back R1
RET							; returns the result to R6 


; Check if At Bottom Left corner
; 	0 if yes and 1 for not
;	XLoc in R4 and YLoc in R5
CheckAtBLCorner:
	PUSH R1 				; PUSH R1 so that it can be used
	XOR R1,R1,R1			; clear R1
	XOR R6,R6,R6			; clear R6
	SETBR R1,0	    		; makes R1 =0001h to compare against YLoc
	XOR R6,R1,R5			; Compare both, if th Y Location matchs then zero saved to R6
	CALL BeforeLBorderLoc	; makes R1=000Fh to compare with XLoc
	XOR R6,R1,R4			; Compare both, if th X Location matchs then zero saved to R6
	POP R1 					; get back R1
RET							; returns the result to R6


; Check if At Bottom Right corner
; 	0 if yes and 1 for not
;	XLoc in R4 and YLoc in R5
CheckAtBRCorner:
	PUSH R1 				; PUSH R1 so that it can be used
	XOR R1,R1,R1			; clear R1
	MOVRR R6,R4				; ADD R4 to R6 as it will be zero if at left corner
	SETBR R1,0    			; makes R1 =0001h to compare against YLoc
	XOR R6,R1,R5			; Compare both, if th Y Location matchs then zero saved to R6
	POP R1 					; get back R1
RET							; returns the result to R6 


; Check if at wall
;	0 if yes else 1 for no
;	YLoc in R5
CheckAtWall:
	PUSH R1 				; PUSH R1 so that it can be used
	CALL BeforeWallLoc 		; R1 = 000Ch
	XOR R6,R1,R5			; compare both, to see if ball at wall
	POP R1 					; get back R1
RET							; returns the result to R6 


; Check if at Left Border
;	0 if yes and 1 for no
;	XLoc in R4
CheckAtLBorder:
	PUSH R1					; push R1
	CALL BeforeLBorderLoc	; R1 = 000Fh
	XOR R6, R1,R4			; compare both, to see if at border
	POP R1 					; get back R1
RET							; returns the result to R6 


; Check if at Right Border
;	0 for yes
;	XLoc at R4
CheckAtRBorder:
	MOVRR R6,R4				;if zero at border
RET							; returns the result to R6 

; Check if at paddle
;	0 for yes
;	YLoc at R5
CheckAtPaddle:
	PUSH R1			
	SETBR R1,0				;R1 = 0001h(just before paddle)
	XOR R6, R1, R5			; compare both, R6=0000h if before paddle
	POP R1
RET							; returns the result to R6 


; Get location before wall
;  returns R1=000Ch
BeforeWallLoc:
	XOR R1,R1,R1			;CLEAR R1
	ADDI R1,R1,6			;R1=0006h
	ADDI R1,R1,6			;R1=000Ch
RET

; Get location at left border
;  returns R1=000Fh
BeforeLBorderLoc:
	XOR R1,R1,R1			;CLEAR R1
	ADDI R1,R1,7			;R1=0007h
	SETBR R1,3				;R1=000Fh
RET

;///////////////////// TO DO ////////////////////

ClrWall:
RET

LoseLife:
RET
