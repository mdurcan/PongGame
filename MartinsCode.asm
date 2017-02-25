; Pong Game
;//////////////////////////////////////////////////////
;//////////////   main of BallUpdate    ///////////////
;//////////////////////////////////////////////////////

BallUpdate: 
	CALL GetDir					; gets direction of the ball
	JZ R6 , Up					; if direction = up, jumps to up else cotinues to down
	
	Down:
		Call GetAngle 			; get angle of ball, Angle in R5
		CALL CheckAngleP45		; checks if ball angle is +45
		JZ R6, DownP45			; if angle = +45
		Call CheckAngleN45		; check if angle is -45
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
		Call GetAngle 			; get angle of ball, Angle in R5
		CALL CheckAngleP45		; checks if ball angle is +45
		JZ R6, UpP45			; if angle = +45
		Call CheckAngleN45		; check if angle is -45
		JZ R6, UpN45			; if angle = -45
		;else angle =vertical
		UpVertical:				; moving up vertical
			
			
			MoveUp:				; move up
			
			RET
			; end MoveUp
		;end UpVertical
		
		UpP45:					; moveing up at +45
			
			MoveUpP45:				; move up at +45
				
			RET	
			; end MoveUpP45
		;end UpP45
		
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

; Get Direction of the ball
; 	0 for up and 1 for down
GetDir:
	MOVRR R6, R0 	; move data to R6
	SHLL R6, 15		; shift data to the left to get direction on its own
RET					; returns the direction


; Get Angle of the Ball
;	00: veritcal, 01: +45 and 10: -45
GetAngle:
	MOVRR R5, R0 	; move data to R5
	SHLL R5, 13		; shift left to get angle and direction
	SHRL R5, 14		; shift right to get angle alone
RET					; returns the angle

; Get X location of ball, outputs R4
GetYLoc:
	MOVRR R4, R0	; move data to R5
	SHLL R4, 4		; shift left to remove Y location
	SHRL R4, 12		; shift right to get X location alone
RET					; return X location


; Get Y location of ball, outputs R5
GetYLoc:
	MOVRR R5, R0	; move data to R5
	SHRL R5, 12		; shift right to get Y location alone
RET					; return Y location
	
	
; Get Wall, outputs R4
GetWall:
	XOR R4,R4,R4	; clear R4
	ADDI R4,R4 1C 	; ADDS 1C to R4
	MOVAMEMR R4, R4 ; moves wall to R4
RET					; returns the wall
	
	
; Check that the Angle is +45 (01)
;	if it returns all 0 then its +45. else not +45
CheckAngleP45:
	MOVRR R6, R5	;move into R6, for caculating
	INVBR R6, 0		; invert bit(0) if it was +45(01) then the last two bits be 00
RET					; returns result


; Check that the Angle is -45 (10)
;	if it returns all 0 then its -45. else not -45	
CheckAngleN45:
	MOVRR R6, R5	;move into R6, for caculating
	INVBR R6, 1		; invert bit(0) if it was -45(10) then the last two bits be 00
RET		


; Check if At wall
; 0 if yes and 1 for not
CheckAtWall:
	
	