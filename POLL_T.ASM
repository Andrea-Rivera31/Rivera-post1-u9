[BITS 16]
[ORG 0x100]

MAX_RETRY EQU 0FFFFh    ; Número máximo de reintentos para el bucle

start:
    MOV CX, MAX_RETRY   ; Cargar el contador de reintentos en CX
.poll:
    IN AL, 64h          ; Leer puerto de estado del teclado
    TEST AL, 01h        ; ¿Dato listo? (OBF = 1)
    JNZ .dato_listo     ; Si está listo, saltar a procesarlo
    LOOP .poll          ; Decrementar CX, si CX != 0 vuelve a .poll

    ; --- Caso Timeout (CX llegó a 0 sin datos) ---
    MOV AH, 09h         ; Función DOS: Mostrar cadena de caracteres
    MOV DX, msg_timeout
    INT 21h
    JMP .fin

.dato_listo:
    IN AL, 60h          ; Leer el byte del teclado
    MOV AH, 02h
    MOV DL, AL          ; Intentar impresión directa del carácter
    INT 21h

.fin:
    MOV AH, 4Ch         ; Terminar programa
    INT 21h

; Datos
msg_timeout DB 'Timeout: sin respuesta del dispositivo$', 0Dh, 0Ah