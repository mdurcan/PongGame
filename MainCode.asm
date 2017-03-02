; ////////////////////////////////////////////////////~~~ Pong Game ~~~//////////////////////////////////////////////////

;//////////////////////////////////////////////////////
;///////////////////	Main	///////////////////////
;//////////////////////////////////////////////////////
main: 
	CALL SetUpGame
END


;//////////////////////////////////////////////////////
;//////////////////	SetUp Game	///////////////////////
;//////////////////////////////////////////////////////
SetUpGame:
	CALL initPaddle				; setup paddle width and position in data memory
	CALL initBall				; allow user to specify ball starting position and direction
	CALL initWall				; set up the wall
	CALL setupTimer				; set up 1sec timer
RET

initPaddle:
	XOR R4, R4, R4				; Clear R4 for use in function
	SETBR R4, 15	
	SHRA R4, 4
	SHRL R4, 6					; R4 = 03E0h (paddle at initial location)
	XOR R5, R5, R5				; Clear R5 for use in function
	SETBR R5, 4					; R5 = 0010h (data memory address for paddle location)
	MOVBAMEM @R5, R4			; Move paddle position to data memory 

	XOR R4, R4, R4				; Clear R4 for use in function
	SETBR R4, 4
	SETBR R4, 5
	SETBR R4, 6					; R4 = 0070
	OR R0, R0, R4				; Moving the paddle location to R0
RET

initBall:
	XOR R4, R4, R4				; Clear R4 for use in function
	SETBR R4, 7					; Set bit to act as ball location 
	XOR R5, R5, R5				; Clear R5 for use in function
	SETBR R5, 0
	SETBR R5, 4					; R5 = 0011h (data memory address for paddle location)
	MOVBAMEM @R5, R4			; Move paddle position to data memory 

	XOR R4, R4, R4				; Clear R4 for use in function
	SETBR R4, 8
	SETBR R4, 9
	SETBR R4, 10				; R4 = 0700
	OR R0, R0, R4				; Moving the ball's x location to R0

	XOR R4, R4, R4				; Clear R4 for use in function
	SETBR R4, 12				; R4 = 1000
	OR R0, R0, R4				; Moving the ball's y location to R0
RET

initWall:
	XOR R4, R4, R4				; Clear R4 for use in function
	INV R4, R4					; R4 = FFFFh
	XOR R5, R5, R5				; Clear R5 for use in function
	SETBR R5, 4
	SETBR R5, 3
	SETBR R5, 2
	SETBR R5, 0					; R5 = 001Dh (memory location of wall)
	MOVBAMEM @R5, R4			; Move wall state to memory
	MOVRR R1, R4				; Move the wall's state to R1
RET


;//////////////////////////////////////////////////////
;//////////////////	SetUp Timer	///////////////////////
;//////////////////////////////////////////////////////
setupTimer: 
	; Setup the LDVAL registers for the timers
	XOR R4, R4, R4	; R4 = 0000h
	INVBR R4, 15	; R4 = 8000h
	SHRA R4, 6		; R4 = FE00h
	SETBR R4, 7		; R4 = FE80h
	SETBR R4, 1		; R4 = FE82h
	MOVRSFR SFR2, R4	; SFR2 = FE82h
	MOVRSFR SFR7, R4	; SFR7 = FE82h

	XOR R4, R4, R4	; Set R4 back to 0000h
	SETBR R4, 11	; R4 = 0800h
	INV R4, R4		; R4 = F7FFh
	SHRL R4, 5		; R4 = 07BFh
	INVBR R4, 15	; R4 = 87BRh
	MOVRSFR SFR1, R4	; SFR1 = 87BRh
	MOVRSFR SFR6, R4	; SFR6 = 87BRh

	; Enabling timers and interrupts
	SETBSFR SFR0, 5	; Enabling timer auto-reload
	SETBSFR SFR0, 3	; Enabling timer interrupt
	SETBSFR SFR0, 0	; Enabling global interrupts
	SETBSFR SFR0, 4	; Enabling timer
RET


;//////////////////////////////////////////////////////
;//////////////	Interupt 1 secound	///////////////////
;//////////////////////////////////////////////////////
ISR2:ORG 116
	CALL PaddleUpdate		; Update the location of the paddle in memory
	CALL BallUpdate			; Update location of ball in memory
RETI

;//////////////////////////////////////////////////////
;////////////////	Paddle Update	///////////////////
;//////////////////////////////////////////////////////

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

;//////////////////////////////////////////////////////
;/////////////////	Ball Update	 //////////////////////
;//////////////////////////////////////////////////////


BallUpdate: 
	CALL GetDir				; gets direction of the ball
	JZ R6 , Up				; if direction = up, jumps to up else cotinues to down
	; else
	Down:
		CALL GetAngle 			; get angle of ball, Angle in R5
		CALL CheckAngleP45		; checks if ball angle is +45
		JZ R6, DownP45			; if angle = +45
		CALL CheckAngleN45		; check if angle is -45
		JZ R6, DownN45			; if angle = -45
		;else angle =vertical
		DownVertical:		; moving Down vertical
			CALL GetYLoc		; get YLoc
			CALL CheckAtPaddle	; checks if at paddle
			JZ R6, AtPaddle		; if yes jumps to AtPaddle
			;else
			MoveDown:			; move down
				MOVRR R3,R5
				SETBR R3,4			
				MOVAMEMR R6, @R3	; gets the Ball from mem
				MOVBAMEM @R3, R7	; clears the where the ball was
				CALL DecYLoc		; decrements and saves YLoc
			RET					
			; end MoveDown
			
			AtPaddle:			; at paddle
				CALL CheckPaddle		; checks if the paddle even there
				JZ R6, LoseLife			; if it not there then jumps to lose life
				CALL GetXLoc			; gets the xlocation
				CALL CheckPaddleR		; checks if at right of paddle
				JZ R6, PaddleN45		; if at right will jump to paddle -45
				CALL CheckPaddleL		; checks if at left of paddle
				JZ R6, PaddleP45		; if at left will jump to paddle +45
				;else
				PaddleVertical:			; moves vertical after hitting paddle
					INVBR R0,0				; invert direction to Up
					CALL AngleVertical		; angle = veritical
				JZ R7, MoveUp
				; end PaddleVertical
			;end of AtPaddle
		;end DownVertical
		
		DownP45:				; moving Down at +45
			CALL GetXLoc		; gets x location
			CALL GetYLoc		; gets y location
			CALL CheckAtBRCorner; checks if at bottom right corner
			JZ R6, AtBRCorner	; if yes will jump to bottom right corner
			CALL CheckAtPaddle	; checks if at paddle
			JZ R6, AtPaddleP45	; if yes jumps to at paddle +45
			CALL CheckAtRBorder	; checks if at right border 
			JZ R6, AtRBorderP45	; if yes jumps to at right border
			;else
			MoveDownP45:		; move down at +45
				MOVRR R3,R5
				SETBR R3,4	
				MOVAMEMR R6, @R3	; gets the Ball from mem
				MOVBAMEM @R3, R7	; clears the where the ball was
				CALL DecXLoc		; decrement and save XLoc
				CALL DecYLoc		; decrements and saves YLoc
			RET
			; end MoveDownP45
			
			AtBRCorner:			; at bottom right corner
				CALL CheckPaddleR		; checks if at right of paddle
				JNZ R6, LoseLife		; if paddle not there lose life
				INVBR R0,0				; invert direction to Up
			JZ R7,MoveUpP45		
			
			AtPaddleP45:		; at paddle
				CALL CheckPaddle		; checks if the paddle even there
				JZ R6, LoseLife			; if it not there then jumps to lose life
				CALL CheckPaddleR		; checks if at right of paddle
				JZ R6, PaddleVertical	; if at right will jump to paddle vertical
				CALL CheckPaddleL		; checks if at left of paddle
				JNZ R6, PaddleN45		; if it isnt at left will jump to paddle -45
				;else
				PaddleP45:			; moves at +45 after hitting paddle
					INVBR R0,0				; invert direction to Up
					CALL AngleP45			; angle = veritical
				JZ R7, MoveUpP45
				; end PaddleP45
			;end of AtPaddleP45
			
			AtRBorderP45:
				CALL AngleN45
			JZ R7, MoveDownN45
		;end DownP45
		
		DownN45:				; moving Down at -45
			CALL GetXLoc		; gets x location
			CALL GetYLoc		; gets y location
			CALL CheckAtBLCorner; checks if at bottom left corner
			JZ R6, AtBLCorner	; if yes will jump to bottom left corner
			CALL CheckAtPaddle	; checks if at paddle
			JZ R6, AtPaddleN45	; if yes jumps to at paddle -45
			CALL CheckAtLBorder	; checks if at left border 
			JZ R6, AtRBorderN45	; if yes jumps to at left border
			;else
			MoveDownN45:		; move down at -45
				MOVRR R3,R5
				SETBR R3,4	
				MOVAMEMR R6, @R3	; gets the Ball from mem
				MOVBAMEM @R3, R7	; clears the where the ball was
				CALL IncXLoc		; increment and save XLoc
				CALL DecYLoc		; decrements and saves YLoc
			RET
			; end MoveDownN45
			
			AtBLCorner:			; at bottom left corner
				CALL CheckPaddleL		; checks if at left of paddle
				JNZ R6, LoseLife		; if paddle not there lose life
				INVBR R0,0				; invert direction to Up
			JZ R7,MoveUpN45	
			
			AtPaddleN45:
				CALL CheckPaddle		; checks if the paddle even there
				JZ R6, LoseLife			; if it not there then jumps to lose life
				CALL CheckPaddleL		; checks if at left of paddle
				JZ R6, PaddleVertical	; if at left will jump to paddle vertical
				CALL CheckPaddleR		; checks if at right of paddle
				JNZ R6, PaddleP45		; if it isnt at right will jump to paddle +45
				;else
				PaddleN45:				; moves at -45 after hitting paddle
					INVBR R0,0				; invert direction to Up
					CALL AngleN45			; angle = veritical
				JZ R7, MoveUpN45
				; end PaddleN45
			;end of AtPaddleN45
			
			AtLBorderN45:
				CALL AngleP45
			JZ R7, MoveDownP45
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
				MOVRR R3,R5
				SETBR R3,4	
				MOVAMEMR R6, @R3	; gets the Ball from mem
				MOVBAMEM @R3, R7	; clears the where the ball was
				CALL IncYLoc		; increments and saves YLoc
			RET
			
			AtWall:
				CALL ClrWallBit		; clear wall
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
				MOVRR R3,R5
				SETBR R3,4	
				MOVAMEMR R6, @R3	; gets the Ball from mem
				MOVBAMEM @R3, R7	; clears the where the ball was
				CALL IncXLoc		; increment and save XLoc
				CALL IncYLoc		; increments and saves YLoc
			RET	
			; end MoveUpP45
			AtTLCorner:			; at the top left corner
				CALL ClrWallBit		; clear wall
				INVBR R0,0			; invert direction to down
			JZ R7, MoveDownP45	; jumps to move down at +45
			
			AtWallP45:			; at wall 
				CALL ClrWallBit		; clear wall
				INVBR R0,0			; invert direction to down
				CALL AngleN45		; changes angle to -45
			JZ R7, MoveDownN45	; jumps to move down at -45
			
			AtLBorderP45:		; at border
				CALL AngleN45		; changes angle to -45
			JZ R7, MoveUpN45	; jumps to move up at -45
		; end UpP45
		
		UpN45:					; moving up at -45
			CALL GetXLoc		; gets x location
			CALL GetYLoc		; gets y location
			CALL CheckAtTRCorner; checks if at top right corner
			JZ R6, AtTRCorner	; if at corner jump to AtTRCorner
			;else
			CALL CheckAtWall	; checks if at wall
			JZ R6, AtWallN45	; if at wall jump to AtWall
			;else
			CALL CheckAtRBorder	; checks if at right border
			JZ R6, AtRBorderN45	; if at right border jump to AtRBorderN45
			;else
			MoveUpN45:			; move up at -45
				MOVRR R3,R5
				SETBR R3,4	
				MOVAMEMR R6, @R3	; gets the Ball from mem
				MOVBAMEM @R3, R7	; clears the where the ball was
				CALL DecXLoc		; increment and save XLoc
				CALL IncYLoc		; increments and saves YLoc
			RET
			; end MoveUpN45
			
			AtTRCorner:			; at top right corner
				CALL ClrWallBit		; clear wall
				INVBR R0,0			; invert direction to down
			JZ R7, MoveDownN45	; jumps to move down at -45
			
			AtWallN45:			; at wall
				CALL ClrWallBit		; clear wall
				INVBR R0,0			; invert direction to down
				CALL AngleP45		; changes angle to +45
			JZ R7, MoveDownP45	; move down at +45
			
			AtRBorderN45:		; at right border
				CALL AngleP45		; changes angle to +45
			JZ R7, MoveUpP45
		;end UpN45
	; end of Up
;end of BallUpdate


;//////////////////////////////////////////////////////
;////////////////	Lose Life	///////////////////////
;//////////////////////////////////////////////////////


LoseLife:
	XOR R4, R4, R4			;R4 = 0000h
	XOR R3, R3, R3			;R3 = 0000h
	ADDI R4, R4, 7			;R4 = 0007h
	ADDI R4, R4, 7			;R4 = 000Eh
	SETBR R4, 4				;R4 = 001Eh
	MOVAMEMR R5, @R4		;R5 = life
	INC R5, R5				;Add lost life
	MOVBAMEM @R4, R5		;Put amount of lost lives into memory
	ADDI R3, R3, 3			;R3 = 0003h
	XOR R6, R5, R3			;Check if all lives are lost
	JNZ R6, 3				;If lives are still available, jump to end
	CALL ClearLives			;Clear lives
	CALL SetUpGame			;Set up a new game
RET

ClearLives:
	XOR R4, R4, R4			;R4 = 0000h
	ADDI R4, R4, 7			;R4 = 0007h
	ADDI R4, R4, 7			;R4 = 000Eh
	SETBR R4, 4				;R4 = 001Eh
	MOVBAMEM @R4, R7		;Put amount of lost lives into memory
RET

;//////////////////////////////////////////////////////
;/////////////////	Clear Wall	///////////////////////
;//////////////////////////////////////////////////////
ClrWallBit:
PUSH R4
PUSH R5
XOR R4, R4, R4				; Clear R4 for use in function
SETBR R4, 4
SETBR R4, 3
SETBR R4, 2
SETBR R4, 0					; R4 = 001Dh (memory location of wall)
MOVAMEMR R3, @R4			; R3 =  wall's state
CALL GetYLoc				; Put ball's y location into R5,
							; Use this location as location of ball in memory
MOVAMEMR R5, @R5			; R5 = memory address contents of ball
INV R5, R5					; Invert ball memory address contents
AND R5, R3, R5				; R5 = updated wall state
MOVBAMEM @R4, R5			; Update wall state
POP R5
POP R4
RET


;//////////////////////////////////////////////////////
;/////////////////	Functions	///////////////////////
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
	

; Get Paddle Loc
GetPaddleLoc:
	MOVRR R5, R0			; move data to R5
	SHLL R5, 8				; shift left and
	SHRL R5, 12				; shift right to get Paddle location alone
RET							; returns paddle location to R5

;//////////////////    Actuator   //////////////////////


; increment paddle location
IncPaddleLoc:
	MOVRR R4, R5
	SHLL R4,4
	XOR R0,R0,R4
	INC R5,R5
	SHLL R5,4
	ADD R0,R0,R5
RET

; increment paddle location
DecPaddleLoc:
	MOVRR R4, R5
	SHLL R4,4
	XOR R0,R0,R4
	DEC R5,R5
	SHLL R5,4
	ADD R0,R0,R5
RET

; increment X location & shifts ball left
IncXLoc:
	MOVRR R3,R4				; use R3 to remove old value
	SHLL R3,8				; shifts to location of XLoc in R0
	XOR R0,R0,R3			; clears old value
	INC R4,R4				; increment XLoc
	SHLL R4,8				; shift to Xloc
	ADD R0, R0, R4			; Saves new XLoc value
	SHLL R6,1				; shifts the ball left
RET


; Decrement X location & shifts ball right
DecXLoc:
	MOVRR R3,R4				; use R3 to remove old value
	SHLL R3,8				; shifts to location of XLoc in R0
	XOR R0,R0,R3			; clears old value
	DEC R4,R4					; Decrement XLoc
	SHLL R4,8				; shift to Xloc
	ADD R0, R0, R4			; Saves new XLoc value
	SHRL R6,1				; shifts the ball right
RET


; increment Y location & and saves the ball
IncYLoc:
	MOVRR R3,R5				; use R3 to remove old value
	SHLL R3,12				; shifts to location of YLoc in R0
	XOR R0,R0,R3			; clears old value
	INC R5,R5				; increment YLoc
	MOVRR R3,R5
	SETBR R3,4	
	MOVBAMEM @R3, R6		; saves ball new location
	SHLL R5,12				; shifts to location of YLoc in R0
	ADD R0, R0, R5			; Saves new YLoc value
RET


; Decrement Y location & and saves ball
DecYLoc:
	MOVRR R3,R5				; use R3 to remove old value
	SHLL R3,12				; shifts to location of YLoc in R0
	XOR R0,R0,R3			; clears old value
	DEC R5,R5				; Decrement YLoc
	MOVRR R3,R5
	SETBR R3,4	
	MOVBAMEM @R3, R6		; saves ball new location
	SHLL R5,12				; shifts to location of YLoc in R0
	ADD R0, R0, R5			; Saves new YLoc value
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

;//////////////////    Checks   //////////////////////	
	
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
	XOR R6,R6,R6			; clear R6
	CALL BeforeWallLoc		; makes R3 =000Ch to compare against YLoc
	XOR R6,R3,R5			; Compare both, if th Y Location matchs then zero saved to R6
	CALL BeforeLBorderLoc	; makes 4h to compare with XLoc
	XOR R6,R3,R4			; Compare both, if th X Location matchs then zero saved to R6
RET							; returns the result to R6


; Check if At Top right corner
; 	0 if yes and 1 for not
;	XLoc in R4 and YLoc in R5
CheckAtTRCorner:
	MOVRR R6,R4				; XLoc will be zero if at top right corner
	CALL BeforeWallLoc   	; Makes R3 =000Ch to compare against YLoc
	XOR R6,R3,R5			; Compare both, if th Y Location matchs then zero saved to R6
RET							; returns the result to R6 


; Check if At Bottom Left corner
; 	0 if yes and 1 for not
;	XLoc in R4 and YLoc in R5
CheckAtBLCorner:
	XOR R3,R3,R3			; clear R3
	XOR R6,R6,R6			; clear R6
	SETBR R3,0	    		; makes R3 =0001h to compare against YLoc
	XOR R6,R3,R5			; Compare both, if th Y Location matchs then zero saved to R6
	CALL BeforeLBorderLoc	; makes R3=000Fh to compare with XLoc
	XOR R6,R3,R4			; Compare both, if th X Location matchs then zero saved to R6
RET							; returns the result to R6


; Check if At Bottom Right corner
; 	0 if yes and 1 for not
;	XLoc in R4 and YLoc in R5
CheckAtBRCorner:
	XOR R3,R3,R3			; clear R3
	MOVRR R6,R4				; ADD R4 to R6 as it will be zero if at left corner
	SETBR R3,0    			; makes R3 =0001h to compare against YLoc
	XOR R6,R3,R5			; Compare both, if th Y Location matchs then zero saved to R6
RET							; returns the result to R6 


; Check if at wall
;	0 if yes else 1 for no
;	YLoc in R5
CheckAtWall:
	CALL BeforeWallLoc 		; R3 = 000Ch
	XOR R6,R3,R5			; compare both, to see if ball at wall
RET							; returns the result to R6 


; Check if at Left Border
;	0 if yes and 1 for no
;	XLoc in R4
CheckAtLBorder:
	CALL BeforeLBorderLoc	; R3 = 000Fh
	XOR R6, R3,R4			; compare both, to see if at border
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
	SETBR R3,0				;R3 = 0001h(just before paddle)
	XOR R6, R3, R5			; compare both, R6=0000h if before paddle
RET							; returns the result to R6 


; Check if paddle below
; 	0 for no
CheckPaddle:
	PUSH R2
	MOVAMEMR R3, @R5		; gets ball
	MOVRR R2, R5
	DEC R2,R2				; gives y location of paddle
	MOVAMEMR R2, @R2		; gets paddle
	AND R6, R3, R2			; gets the bit below ball, if paddle there it will not be 0000h
	POP R2
RET							;returns result to R6


; Check if at Right of PaddleN45
;	0 if yes
CheckPaddleR:
	CALL GetPaddleLoc		; gets paddle location, which is also location of right
	XOR R6,R4,R5			; compare both, R6 =0000h 
RET							;returns result to R6


; Check if at left of paddle
;	0 if yes
CheckPaddleL:
	CALL GetPaddleLoc		; gets paddle location
	ADDI R5,R5,4			; Add 4 to get left side of paddle location
	XOR R6,R4,R5			; compare both, R6 =0000h 
RET							;returns result to R6


; Get location before wall
;  returns R3=000Ch
BeforeWallLoc:
	XOR R3,R3,R3			;CLEAR R3
	ADDI R3,R3,6			;R3=0006h
	ADDI R3,R3,6			;R3=000Ch
RET

; Get location at left border
;  returns R3=000Fh
BeforeLBorderLoc:
	XOR R3,R3,R3			;CLEAR R3
	ADDI R3,R3,7			;R3=0007h
	SETBR R3,3				;R3=000Fh
RET


;///////////////// Paddle Functions //////////////////////////

CheckPaddleAtL:
	CALL GetPaddleLoc		;Call GetPaddleLoc for paddle location
	XOR R4,R4,R4			;R4 = 0000h
	ADDI R4,R4,6			;R4 = 0006h
	ADDI R4,R4,7			;R4 = 000Dh
	XOR R6,R4,R5			;R6 = R4 - R5
RET

CheckPaddleAtR:
	CALL GetPaddleLoc		;Call GetPaddleLoc for paddle location
	XOR R4,R4,R4			;R4 = 0000h
	ADDI R4,R4,2			;R4 = 0002h
	XOR R6,R4,R5			;R6 = R4 - R5
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
	CALL DecPaddleLoc		; decrement paddle location
	XOR R4,R4,R4			;R4 = 0000h
	SETBR R4,4				;R4 = 0010h
	MOVAMEMR R5,@R4			;Put value from memory address in R4 to R5
	SHRL R5,1				;Shift value in R5 right by 1
	MOVBAMEM @R4,R5			;Put value in R5 to memory address in R4
RET

ShiftPaddleLeft:
	CALL IncPaddleLoc
	XOR R4,R4,R4			;R4 = 0000h
	SETBR R4,4				;R4 = 0010h
	MOVAMEMR R5,@R4			;Put value from memory address in R4 to R5
	SHLL R5,1				;Shift value in R5 left by 1
	MOVBAMEM @R4,R5			;Put value in R5 to memory address in R4
RET