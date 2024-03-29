;**************************************************************************
;   Autores:
;       Rafael Sanchez Sanchez - rafael.sanchezs@estudiante.uam.es
;       Alejandro Santorum Varela - alejandro.santorum@estudiante.uam.es
;   Pareja: 16
;   Practica 4 Sistemas Basados en Microprocesadores
;**************************************************************************
DATOS SEGMENT
    MTXOUT      DB "  | 1 | 2 | 3 | 4 | 5 | 6 |", 13, 10
                DB "1 | V | W | X | Y | Z | 0 |", 13, 10
                DB "2 | 1 | 2 | 3 | 4 | 5 | 6 |", 13, 10
                DB "3 | 7 | 8 | 9 | A | B | C |", 13, 10
                DB "4 | D | E | F | G | H | I |", 13, 10
                DB "5 | J | K | L | M | N | O |", 13, 10
                DB "6 | P | Q | R | S | T | U |", 13, 10, "$"
    TEMP        DB "HOLA$"
    ARROW       DB " -> $"
    TEMP2       DB "54 66 55 41 56$"
    LINEFEED    DB 13, 10, "$"
    NOTINS      DB "EL DRIVER SE ENCUENTRA DESINSTALADO$"
DATOS ENDS

CODIGO SEGMENT
ASSUME CS: CODIGO, DS:DATOS

;_____________________________________________________
;  IMPRIME UNA NUEVA LINEA
;_____________________________________________________
NEWLINE PROC
    PUSH DX AX
    LEA DX, LINEFEED
    MOV AH, 9H
    INT 21H
    POP AX DX
    RET
NEWLINE ENDP

INICIO PROC
    MOV AX, DATOS
    MOV DS, AX

    MOV BX, 0
    MOV ES, BX
    CMP WORD PTR ES:[57H*4+2], 0
    JE NOTINSTALLED

    LEA DX, MTXOUT
    MOV AH, 9H
    INT 21H

    LEA DX, TEMP
    INT 21H

    LEA DX, ARROW
    INT 21H

    LEA DX, TEMP
    MOV AH, 10H
    MOV CX, 0
    INT 57H

    CALL NEWLINE

    LEA DX, TEMP2
    MOV AH, 9H
    INT 21H

    LEA DX, ARROW
    INT 21H

    LEA DX, TEMP2
    MOV AH, 11H
    MOV CX, 0
    INT 57H

    CALL NEWLINE
    JMP FIN

    NOTINSTALLED:
    LEA DX, NOTINS
    MOV AH, 9
    INT 21H

    FIN:
    MOV AX, 4C00H
    INT 21H
INICIO ENDP

CODIGO ENDS
END INICIO
