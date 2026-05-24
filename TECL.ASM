; =========================================================
; PROYECTO: CAPTURA DE PERIFÉRICOS (MÉTODO COMPATIBLE MAC)
; DESARROLLADO PARA ENTORNO EMULADO EN MAC (DOSBOX)
; =========================================================

[BITS 16]
[ORG 0x100]         ; Formato ejecutable COM estándar

inicio:
    ; --- MENSAJE INICIAL DE CONTROL ---
    MOV AH, 09h
    MOV DX, msg_inicio
    INT 21h

bucle_principal:
    ; Emulación del puerto mediante interrupción compatible con Mac
    ; Espera de forma segura a que se presione una tecla sin colgar el procesador
    MOV AH, 00h         
    INT 16h             ; Leer buffer de teclado de la BIOS
    
    ; Al presionar cualquier tecla: 
    ; AH recibe el Scancode de hardware y AL recibe el carácter ASCII
    MOV DH, AH          ; Mover el SCANCODE a DH para el procesamiento requerido

    ; --- FILTRO DE SALIDA: Si presionas la tecla ESC (Scancode 01h), salir ---
    CMP DH, 01h
    JE salida_segura

    ; -----------------------------------------------------
    ; PROCESAR E IMPRIMIR DÍGITO ALTO (NIBBLE SUPERIOR)
    ; -----------------------------------------------------
    MOV CL, DH
    SHR CL, 4           ; Aislar los 4 bits superiores del scancode
    CALL transformar_ascii
    MOV DL, AL
    MOV AH, 02h         ; Función DOS para imprimir carácter
    INT 21h             ; Mostrar en pantalla

    ; -----------------------------------------------------
    ; PROCESAR E IMPRIMIR DÍGITO BAJO (NIBBLE INFERIOR)
    ; -----------------------------------------------------
    MOV CL, DH
    AND CL, 0Fh         ; Aislar los 4 bits inferiores del scancode
    CALL transformar_ascii
    MOV DL, AL
    MOV AH, 02h
    INT 21h             ; Mostrar en pantalla

    ; --- IMPRIMIR UN ESPACIO EN BLANCO ---
    MOV AH, 02h
    MOV DL, 20h         ; Carácter espacio ' '
    INT 21h

    JMP bucle_principal ; Volver a esperar la siguiente tecla de forma infinita

salida_segura:
    ; --- Salto de línea final antes de salir ---
    MOV AH, 02h
    MOV DL, 0Dh         ; CR
    INT 21h
    MOV DL, 0Ah         ; LF
    INT 21h

    MOV AH, 4Ch         ; Terminar programa de forma limpia
    INT 21h             ;

; =========================================================
; SUBRUTINA: CONVERSIÓN DE VALOR NUMÉRICO A CARÁCTER ASCII
; =========================================================
transformar_ascii:
    CMP CL, 0Ah
    JGE es_letra
    ADD CL, 30h         ; Transformar a '0'-'9'
    JMP asignar
es_letra:
    ADD CL, 37h         ; Transformar a 'A'-'F'
asignar:
    MOV AL, CL
    RET

; --- SECCIÓN DE DATOS ---
msg_inicio DB 'Monitoreando... Presione teclas (ESC para salir):', 0Dh, 0Ah, '$'