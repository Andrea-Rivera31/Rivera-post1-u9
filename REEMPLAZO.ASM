; =====================================================================
; LPT1.ASM
; =====================================================================

[BITS 16]
[ORG 0x100]

; Definición de constantes asociadas a los mapas de puertos base de LPT1
DATA_PORT   equ 0378h       
STATUS_PORT equ 0379h       
CTRL_PORT   equ 037Ah       

start:
.wait_ready:
    mov bx, STATUS_PORT     ; Cargar la dirección de estado en BX de forma interna
    mov dx, bx              ; Pasar el valor al registro DX requerido por IN
    in al, dx               ; Lee el estado actual de la impresora
    test al, 80h            ; Comprueba el Bit 7 (Señal BUSY#, activa en bajo)
    jz .wait_ready          ; Si el bit es 0, la línea indica ocupación; reintenta

    ; --- TRANSMISIÓN DEL DATO ---
    mov ah, 41h             ; Carga el código ASCII del carácter "A" (0x41) en AH
    mov al, ah              ; Mueve el valor a AL para preparar la salida física
    mov dx, DATA_PORT
    out dx, al              ; Envía físicamente el byte al bus del puerto de datos

    ; --- ACTIVACIÓN DEL PULSO STROBE (Bit 0 de Control, activo en bajo) ---
    mov dx, CTRL_PORT
    in al, dx               ; Lee el estado actual de las líneas de control internas
    and al, 0FEh            ; Limpia el bit 0 (Fuerza STROBE = 0)
    out dx, al              ; Aplica el cambio eléctrico en el puerto físico

    ; --- RETARDO DE TIEMPO REQUERIDO (Estabilización del pulso ~1us) ---
    mov cx, 000Fh           ; Inicializa un bucle de retardo corto para DOSBox
.delay:
    loop .delay             ; Decrementa CX de forma esporádica hasta llegar a cero

    ; --- DESACTIVACIÓN DEL PULSO STROBE (Fuerza STROBE = 1) ---
    or al, 01h              ; Enciende el bit 0 mediante una operación lógica OR
    out dx, al              ; Devuelve la línea de control a su estado inactivo original

    ; --- RETORNO AL SISTEMA ---
    mov ax, 4C00h           ; Definición de la función de salida usando la palabra completa AX
    int 21h                 ; Finaliza la ejecución sin errores