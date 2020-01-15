;-------------------------------------------------------------------------------
;|  Título:         PIT_Set_Counter0                                           |
;|  Versión:        1.0                     Fecha:  24/08/2014                 |
;|  Autor:          Andrea Pirlo            Modelo: IA-32 (16/32bits)          |
;|  ------------------------------------------------------------------------   |
;|  Descripción:                                                               |
;|      Reprograma el Temporizador 0 del PIT (Programmable Internal Timer)     |
;|  ------------------------------------------------------------------------   |
;|  Recibe:                                                                    |
;|      cx:     Periodo de interrupcion expresado en multiplos de 1mseg.       |
;|              Debe ser inferior a 54.                                        |
;|                                                                             |
;|  Retorna:                                                                   |
;|      Nada                                                                   |
;|  ------------------------------------------------------------------------   |
;|  Revisiones:                                                                |
;|      1.0 | 15/02/2010 | D.GARCIA  | Original                                |
;|      2.0 | 01/06/2017 | ChristiaN | Se agrega argumento para intervalo      |
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;7 6 5 4 3 2 1 0   <-- Número de bit de la palabra de control
;| | | | | | | |
;| | | | | | | +-- Modo BCD:
;| | | | | | |     0 - El contador trabajará en formato binario de 16 bits
;| | | | | | |     1 - El contador trabajará en formato BCD con cuatro dígitos 
;| | | | | | |          decimales
;| | | | +-+-+---- Modo de operación para el contador:
;| | | |           000 - Modo 0. Interrupt on Terminal Count (Interrumpe al terminar el conteo)
;| | | |           001 - Modo 1. Hardware Retriggerable One-Shot (Disparo programable)
;| | | |           X10 - Modo 2. Rate Generator (Generador de impulsos). El valor del bit más significativo no importa
;| | | |           X11 - Modo 3. Square Wave(Generador de onda cuadrada). El valor del bit más significativo no importa
;| | | |           100 - Modo 4. Software Triggered Strobe (Strobe disparado por software)
;| | | |           101 - Modo 5. Hardware Triggered Strobe (Retriggerable) (Strobe disparado por hardware)
;| | | |
;| | +-+---------- Modo de acceso (lectura/escritura) para el valor del contador:
;| |               00 - Counter Latch. El valor puede ser leído de la manera en que fue ajustado previamente.
;| |                                   El valor es mantenido hasta que es leído o sobreescrito.
;| |               01 - Lee (o escribe) solo el byte menos significativo del contador (bits 0-7)
;| |               10 - Lee (o escribe) solo el byte más significativo del contador (bits 8-15)
;| |               11 - Primero se lee (o escribe) el byte menos significativo del contador, y luego el byte más significativo
;| |
;+-+-------------- Selección del contador:
;                  00 - Se selecciona el contador 0
;                  01 - Se selecciona el contador 1
;                  10 - Se selecciona el contador 2
;                  11 - No usado. (solo hay 3 contadores)
;                  (Los demás bits de la palabra de control indican cómo será programado el contador seleccionado)

SECTION .init progbits
GLOBAL __pit_configure


;If a frequency of 100 hz is desired, we see that the necessary divisor is 1193182 / 100 = 11931. 
;This value must be sent to the PIT split into a high and low byte.

USE32
__pit_configure:
   mov al, 0x34    ; 0011 0100
   out 0x43, al    ;tell the PIT which channel we're setting

   mov ax, 11932   ;seteo para que interrumpa cada 10ms:  X = 1193182/100 = 11932
   out 0x40, al    ;send low byte
   mov al, ah
   out 0x40, al    ;send high byte
   ret
