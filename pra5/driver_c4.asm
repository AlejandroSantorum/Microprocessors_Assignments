;**************************************************************************
;   Author:
;       Alejandro Santorum Varela - alejandro.santorum@estudiante.uam.es
;   Assignment 5 (optional) Sistemas Basados en Microprocesadores
;**************************************************************************
CODIGO SEGMENT
ASSUME CS: CODIGO
ORG 256
INICIO:
JMP INSTALLER
; GLOBAL VARIABLES
HELP_MSG DB ""
INSTALLED_MSG DB "Driver instalado exitosamente",13,"$"
UNINSTALLED_MSG DB "Driver desinstalado",13,"$"


COUNTER DW 0
SIGN DW 0CE11h
DRIVER_MAIN PROC FAR
    STI

    IRET
DRIVER_MAIN ENDP


INSTALLER PROC FAR
    CMP BYTE PTR DS:[80H], 0 ; CHECKING INPUT PARAMETERS
    JE HELP
    MOV BL, DS:[83H]
    CMP BL, 'i'
    JE INSTALL
    CMP BL, 'd'
    JE UNINSTALL

    HELP:
    MOV AH, 9H
    MOV DX, OFFSET HELP_MSG
    INT 21H
    JMP END_HELP


    INSTALL:
    MOV AX, 0
    MOV ES, AX

    CMP WORD PTR ES:[70H*4+2], 0 ; CHECKS IF IT'S FREE
    JNE END_INSTALLER

    ;;;;;; SETTING UP RTC ;;;;;;;;;;;
    ;; REGISTER A
    MOV BL, 00101111b ; UIP=0 DV=010 RS=1111
    MOV AL, 0AH
    OUT 70H, AL
    MOV AL, BL
    OUT 71H, AL
    ;; REGISTER B
    MOV AL, 0BH
    OUT 70H, AL
    IN AL, 71H ; READING CURRENT REGISTER B VALUE
    MOV BL, AL
    OR BL, 01000000b ; PIE = 1 (Periodic interruptions)
    MOV AL, 0BH
    OUT 70H, AL
    MOV AL, BL
    OUT 71H, AL ; WRITING NEW REGISTER B VALUE (Activating periodic int)


    MOV AX, OFFSET DRIVER_MAIN
    MOV BX, CS
    CLI                 ; INSTALLING
        MOV ES:[70H*4], AX  ; OFFSET MAIN
        MOV ES:[70H*4+2], BX ; OFFSET CODE SEGMENT
    STI

    END_INSTALLER:
    MOV AX, CS
    MOV DS, AX
    LEA DX, INSTALLED_MSG
    MOV AH, 9H
    INT 21H
    MOV DX, OFFSET INSTALLER
    INT 27H

    UNINSTALL:
    MOV CX, 0
    MOV DS, CX

    CMP WORD PTR DS:[70H*4+2], 0 ; CHECKING THERE'S SOMETHING INSTALLED
    JE END_UNINSTALL

    LES BX, DS:[70H*4]
    CMP WORD PTR ES:[BX-2], 0CE11H ;SIGN
    JNE END_UNINSTALL

    MOV ES, DS:[70H*4+2]
    MOV BX, ES:[2CH]
    MOV AH, 49H
    INT 21H ;FREEING RSI SEGMENT
    MOV ES, BX
    INT 21H ;FREEING ENVIRONMENT VARIABLES SEGMENT
    CLI
        MOV WORD PTR DS:[70H*4], 0
        MOV WORD PTR DS:[70H*4+2], 0
    STI

    END_UNINSTALL:
    MOV AX, CS
    MOV DS, AX
    LEA DX, UNINSTALLED_MSG
    MOV AH, 9
    INT 21H

    END_HELP:
    MOV AX, 4C00H
    INT 21H

INSTALLER ENDP

CODIGO ENDS
END INICIO
