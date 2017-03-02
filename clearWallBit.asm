; SoC Design Pong Game
; Aoife McDonagh, 13411348
; Martin Durcan
; Tara Bourke
;
;
;
ClrWallBit:
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