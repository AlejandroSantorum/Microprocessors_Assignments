;**************************************************************************
;   Author:
;       Alejandro Santorum Varela - alejandro.santorum@estudiante.uam.es
;   Assignment 5 (optional) Sistemas Basados en Microprocesadores
;**************************************************************************

; DATA SEGMENT
DATOS SEGMENT
; INIT STRINGS
    WELCOME_STR DB "Bienvenido al juego Conecta 4, implementado por Alejandro Santorum",13,10, "$"
    ASK_COL1 DB "JUGADOR 1 -> Introduzca columna donde desea jugar (numero entre 0 y 6): $"
    ASK_COL2 DB "JUGADOR 2 -> Introduzca columna donde desea jugar (numero entre 0 y 6): $"
    BOARD   DB "| | | | | | | |", 13, 10
            DB "| | | | | | | |", 13, 10
            DB "| | | | | | | |", 13, 10
            DB "| | | | | | | |", 13, 10
            DB "| | | | | | | |", 13, 10
            DB "| | | | | | | |", 13, 10
            DB " 0 1 2 3 4 5 6", 13, 10, "$"
    HEIGHTS DB -1,-1,-1,-1,-1,-1,-1
    TURN DB 0
    INVALID_COL_ERR DB "Error: la columna introducida no es valida. Intentelo de nuevo.",13,10, "$"
    FULL_COL_ERR DB "Error: la columna introducida esta llena. Seleccione otra.",13,10,"$"
    WINNER_STR DB "Felicidades, ha ganado el jugador $"
	LINE_FEED DB 13,10,'$'

    ;; FOR THE NEXT VARIABLES IS IMPORTANT TO KEEP IN MIND THE BOARD OFFSETS:
    ;;
    ;; |01|03|05|07|09|11|13|
    ;; |18|20|22|24|26|28|30|
    ;; |35|37|39|41|43|45|47|
    ;; |52|54|56|58|60|62|64|
    ;; |69|71|73|75|77|79|81|
    ;; |86|88|90|92|94|96|98|
    ;;

    ; ALL VERTICAL 4-COMBINATIONS
    VERT  DW 1,18,35,52,18,35,52,69,35,52,69,86
          DW 3,20,37,54,20,37,54,71,37,54,71,88
          DW 5,22,39,56,22,39,56,73,39,56,73,90
          DW 7,24,41,58,24,41,58,75,41,58,75,92
          DW 9,26,43,60,26,43,60,77,43,60,77,94
          DW 11,28,45,62,28,45,62,79,45,62,79,96
          DW 13,30,47,64,30,47,64,81,47,64,81,98

    ; ALL HORIZONTAL 4-COMBINATIONS
    HORIZ DW 1,3,5,7,3,5,7,9,5,7,9,11,7,9,11,13
          DW 18,20,22,24,20,22,24,26,22,24,26,28,24,26,28,30
          DW 35,37,39,41,37,39,41,43,39,41,43,45,41,43,45,47
          DW 52,54,56,58,54,56,58,60,56,58,60,62,58,60,62,64
          DW 69,71,73,75,71,73,75,77,73,75,77,79,75,77,79,81
          DW 86,88,90,92,88,90,92,94,90,92,94,96,92,94,96,98

    ; ALL POSITIVE DIAGONAL 4-COMBINATIONS
    POSDIAG DW 52,37,22,7
            DW 69,54,39,24,54,39,24,9
            DW 86,71,56,41,71,56,41,26,56,41,26,11
            DW 88,73,58,43,73,58,43,28,58,43,28,13
            DW 90,75,60,45,75,60,45,30
            DW 92,77,62,47

    ; ALL NEGATIVE DIAGONAL 4-COMBINATIONS
    NEGDIAG DW 35,54,73,92
            DW 18,37,56,75,37,56,75,94
            DW 1,20,39,58,20,39,58,77,39,58,77,96
            DW 3,22,41,60,22,41,60,79,41,60,79,98
            DW 5,24,43,62,24,43,62,81
            DW 7,26,45,64

DATOS ENDS


;**************************************************************************
; STACK SEGMENT
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS
;**************************************************************************
; EXTRA SEGMENT
EXTRA SEGMENT
EXTRA ENDS
;**************************************************************************
; CODE SEGMENT
CODIGO SEGMENT
ASSUME CS: CODIGO, DS: DATOS, ES: EXTRA, SS: PILA
; MAIN

;_____________________________________________________
;  INPUT: DS:DX -> ADDRESS OF THE STRING TO PRINT
;  OUTPUT : NONE.
;_____________________________________________________
PRINTF PROC FAR
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
PRINTF ENDP


;_____________________________________________________
;  INPUT: AL -> INTRODUCED COLUMN ID
;  OUTPUT : AH -> 1 IF INTRODUCED COL IS AVAILABLE, 0 OTHERWISE
;_____________________________________________________
CHECK_COL PROC FAR
    PUSH BX
    ; GETTING HEIGHT OF THE DESIRED COL
    MOV BX, 0
    MOV BL, AL
    MOV BL, DS:HEIGHTS[BX]
    ; CHECKING IT IS NOT FULL
    CMP BL, 5
    JL AVAILABLE
    MOV AH, 0 ; FULL
    JMP FIN_CHECK

    AVAILABLE:
    MOV AH, 1 ; NOT FULL

    FIN_CHECK:
    POP BX
    RET
CHECK_COL ENDP


;_____________________________________________________
;  INPUT: AL -> INTRODUCED COLUMN ID
;  OUTPUT : None
;_____________________________________________________
INSERT_PIECE PROC FAR
    PUSH BX CX DI SI
    ; GETTING HEIGHT OF THE DESIRED COL
    MOV BX, 0
    MOV BL, AL
    MOV CH, 0
    MOV CL, DS:HEIGHTS[BX]
    ; UPDATING COLUMN HEIGHT
    INC CL
    MOV DS:HEIGHTS[BX], CL
    ; AUX VARIBLE WITH MAXIMUM HEIGHT VALUE
    MOV BX, 5
    ; GETTING ROW WHERE WE'LL INSERT
    SUB BX, CX ; ROW = 5 - HEIGHT[COL]
	MOV SI, BX
	SHL BX, 1
	SHL BX, 1
	SHL BX, 1
	SHL BX, 1
	ADD BX, SI ; ROW *= 17 (NUMBER OF CHARACTERS PER ROW)
    ; GETTING COLUMN WHERE WE'LL INSERT
    MOV DI, 0
	MOV AH, 0
    MOV DI, AX ; DI = COL
    ADD DI, DI ; COL *= 2
    INC DI     ; COL += 1
    CMP TURN, 0
    JE INSERT_PLAYER1
    ; PLAYER 2'S TURN
    MOV CL, "*" ; PIECE OF PLAYER 2
    MOV DS:BOARD[BX + DI], CL
    JMP FIN_INSERT

    INSERT_PLAYER1: ; PLAYER 1'S TURN
    MOV CL, "o" ; PIECE OF PLAYER 1
    MOV DS:BOARD[BX + DI], CL

    FIN_INSERT:
    POP SI DI CX BX
    RET
INSERT_PIECE ENDP


;_____________________________________________________
;  INPUT: DL -> PIECE CHARACTER TO COMPARE
;  OUTPUT : AH -> 1 IF USER HAS WON, 0 OTHERWISE
;_____________________________________________________
CHECK_VERT PROC FAR
    PUSH BX CX SI
    MOV CX, 0
    VERT_LOOP:
    MOV BX, CX ; BX = COMBINATION COUNTER
    SHL BX, 1
    SHL BX, 1
	SHL BX, 1 ; BX *= 8
    MOV SI, DS:VERT[BX] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_VERT
    MOV SI, DS:VERT[BX+2] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_VERT
    MOV SI, DS:VERT[BX+4] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_VERT
    MOV SI, DS:VERT[BX+6] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_VERT
    ; FOUND CONNECTION OF 4 PIECES
    MOV AH, 1
    JMP END_VERT

    CONTINUE_VERT:
    INC CX
    CMP CX, 21 ; 21 IS THE NUMBER OF VERTICAL 4-COMBINATIONS
    JE NOT_END_VERT
    JMP VERT_LOOP

    NOT_END_VERT: ; CONNECTION OF 4 NOT FOUND
    MOV AH, 0
    END_VERT:
    POP SI CX BX
    RET
CHECK_VERT ENDP


;_____________________________________________________
;  INPUT: DL -> PIECE CHARACTER TO COMPARE
;  OUTPUT : AH -> 1 IF USER HAS WON, 0 OTHERWISE
;_____________________________________________________
CHECK_HORIZ PROC FAR
    PUSH BX CX SI
    MOV CX, 0
    HORIZ_LOOP:
    MOV BX, CX
    SHL BX, 1
    SHL BX, 1
	SHL BX, 1 ; BX *= 8
    MOV SI, DS:HORIZ[BX] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_HORIZ
    MOV SI, DS:HORIZ[BX+2] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_HORIZ
    MOV SI, DS:HORIZ[BX+4] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_HORIZ
    MOV SI, DS:HORIZ[BX+6] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_HORIZ
    ; FOUND CONNECTION OF 4 PIECES
    MOV AH, 1
    JMP END_HORIZ

    CONTINUE_HORIZ:
    INC CX
    CMP CX, 24 ; 24 IS THE NUMBER OF HORIZONTAL 4-COMBINATIONS
    JE NOT_END_HORIZ
    JMP HORIZ_LOOP

    NOT_END_HORIZ: ; CONNECTION OF 4 NOT FOUND
    MOV AH, 0
    END_HORIZ:
    POP SI CX BX
    RET
CHECK_HORIZ ENDP


;_____________________________________________________
;  INPUT: DL -> PIECE CHARACTER TO COMPARE
;  OUTPUT : AH -> 1 IF USER HAS WON, 0 OTHERWISE
;_____________________________________________________
CHECK_POSDIAG PROC FAR
    PUSH BX CX SI
    MOV CX, 0
    POSDIAG_LOOP:
    MOV BX, CX
    SHL BX, 1
    SHL BX, 1
	SHL BX, 1 ; BX *= 8
    MOV SI, DS:POSDIAG[BX] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_POSDIAG
    MOV SI, DS:POSDIAG[BX+2] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_POSDIAG
    MOV SI, DS:POSDIAG[BX+4] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_POSDIAG
    MOV SI, DS:POSDIAG[BX+6] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_POSDIAG
    ; FOUND CONNECTION OF 4 PIECES
    MOV AH, 1
    JMP END_POSDIAG

    CONTINUE_POSDIAG:
    INC CX
    CMP CX, 12 ; 12 IS THE NUMBER OF POSITIVE DIAGONAL 4-COMBINATIONS
    JE NOT_END_POSDIAG
    JMP POSDIAG_LOOP

    NOT_END_POSDIAG: ; CONNECTION OF 4 NOT FOUND
    MOV AH, 0
    END_POSDIAG:
    POP SI CX BX
    RET
CHECK_POSDIAG ENDP


;_____________________________________________________
;  INPUT: DL -> PIECE CHARACTER TO COMPARE
;  OUTPUT : AH -> 1 IF USER HAS WON, 0 OTHERWISE
;_____________________________________________________
CHECK_NEGDIAG PROC FAR
    PUSH BX CX SI
    MOV CX, 0
    NEGDIAG_LOOP:
    MOV BX, CX
    SHL BX, 1
    SHL BX, 1
	SHL BX, 1 ; BX *= 8
    MOV SI, DS:NEGDIAG[BX] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_NEGDIAG
    MOV SI, DS:NEGDIAG[BX+2] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_NEGDIAG
    MOV SI, DS:NEGDIAG[BX+4] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_NEGDIAG
    MOV SI, DS:NEGDIAG[BX+6] ; SI = INDEX OF COMBINATION
    CMP BOARD[SI], DL
    JNE CONTINUE_NEGDIAG
    ; FOUND CONNECTION OF 4 PIECES
    MOV AH, 1
    JMP END_NEGDIAG

    CONTINUE_NEGDIAG:
    INC CX
    CMP CX, 12 ; 12 IS THE NUMBER OF NEGATIVE DIAGONAL 4-COMBINATIONS
    JE NOT_END_NEGDIAG
    JMP NEGDIAG_LOOP

    NOT_END_NEGDIAG: ; CONNECTION OF 4 NOT FOUND
    MOV AH, 0
    END_NEGDIAG:
    POP SI CX BX
    RET
CHECK_NEGDIAG ENDP

;_____________________________________________________
;  INPUT: None
;  OUTPUT : AH -> 1 IF USER HAS WON, 0 OTHERWISE
;_____________________________________________________
CHECK_WINNER PROC FAR
    PUSH DX
    ; GETTING PIECE TO COMPARE
    CMP TURN, 0
    JE PIECE0
    MOV DL, "*" ; PIECE OF PLAYER 2
    JMP CHECK_WINNER_L
    PIECE0:
    MOV DL, "o" ; PIECE OF PLAYER 1
    CHECK_WINNER_L:
    CALL CHECK_VERT
    CMP AH, 1
    JE END_CHECK_WINNER
    CALL CHECK_HORIZ
    CMP AH, 1
    JE END_CHECK_WINNER
    CALL CHECK_POSDIAG
    CMP AH, 1
    JE END_CHECK_WINNER
    CALL CHECK_NEGDIAG
    END_CHECK_WINNER:
    POP DX
    RET
CHECK_WINNER ENDP


INICIO PROC FAR
    ;INITIALIZING SEGMENTS
    MOV AX, DATOS
    MOV DS, AX
    MOV AX, PILA
    MOV SS, AX
    MOV AX, EXTRA
    MOV ES, AX
    MOV SP, 40h
    ; PRINTING WELCOME
    MOV DX, OFFSET WELCOME_STR
    CALL PRINTF

    MAIN_LOOP:
    ; PRINTING BOARD
    MOV DX, OFFSET BOARD
    CALL PRINTF
    ; CHECKING TURN
    CMP TURN, 0
    JE TURN1

    TURN2:
    ; ASKING PLAYER 2 TO CHOOSE A COL
    MOV DX, OFFSET ASK_COL2
    CALL PRINTF
    JMP GET_COL

    TURN1:
    ; ASKING PLAYER 1 TO CHOOSE A COL
    MOV DX, OFFSET ASK_COL1
    CALL PRINTF

    GET_COL:
    MOV AH, 1
    INT 21H
	MOV DX, OFFSET LINE_FEED
	MOV AH, 9
	INT 21H
    ; CHECKING INTRODUCED COL IS NO BIGGER THAN 6 (36H)
    CMP AL, 36H
    JA PRINT_INVALID_COL_ERR ; ERROR
    ; CHECKING INTRODUCED COL IS 0 (30H) OR GREATER
    CMP AL, 30H
    JB PRINT_INVALID_COL_ERR ; ERROR
    ; GETTING COLUMN AS AN INTEGER
    SUB AL, 30H
    CALL CHECK_COL
    CMP AH, 0
    JE PRINT_FULL_COL_ERR ; ERROR
    ; INTRODUCING PIECE
    CALL INSERT_PIECE
    ; CHECKING IF THE GAME IS FINISHED
    CALL CHECK_WINNER
    CMP AH, 1
    JE PRINT_WINNER ; FINISHED
    ; CHANGING PLAYER TURN
    XOR TURN, 1
    JMP MAIN_LOOP



    PRINT_INVALID_COL_ERR:
    MOV DX, OFFSET INVALID_COL_ERR
    CALL PRINTF
    JMP MAIN_LOOP
    PRINT_FULL_COL_ERR:
    MOV DX, OFFSET FULL_COL_ERR
    CALL PRINTF
    JMP MAIN_LOOP

    PRINT_WINNER:
    MOV DX, OFFSET BOARD
    CALL PRINTF
    MOV DX, OFFSET WINNER_STR
    CALL PRINTF
    MOV DL, TURN
    ADD DL, 31H ; ADDING 30H TO CONVERT TO ASCII AND +1 TO CHANGE TURN 0 = PLAYER 1, TURN 1 = PLAYER 2
    MOV AH, 2
    INT 21h

    FIN:
    MOV AX, 4C00H
    INT 21H
INICIO ENDP
CODIGO ENDS
END INICIO
