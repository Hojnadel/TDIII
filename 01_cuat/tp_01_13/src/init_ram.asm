%define BREAKPOINT  xchg bx,bx

USE32


section .copy
;***********************************************************************;
; __COPY_IN_RAM: Función que copia memoria en memoria. Recibe:          ;
;1_ Dirección Fuente                                                    ;
;2_ Dirección Destino                                                   ;
;3_ Tamaño                                                              ;
;***********************************************************************;
  copy:
    mov ebp, esp    	;cargo el puntero de pila en EBP
    mov ecx, [ebp+4]  	; Cantidad
	    cmp ecx, 0
	    jz .exit
    mov edi, [ebp+8] 	; Destino
    mov esi, [ebp+12] 	; Origen
  	.ciclo_copy:
	    mov al, [esi]   ;cargo en un registro el contenido de esi
	    mov [edi], al   ;cargo en edi el contenido de al
	    inc esi       ;incremento los punteros
	    inc edi       ;incremento los punteros
	    dec ecx       ;decremento el contador
	    jne .ciclo_copy    ;si el flag NO está en 0, salto a ciclo
    .exit:
    ret         ;salgo



;***********************************************************************************************************************;

section .init_RAM

GLOBAL  init_ram_itty_map
init_ram_itty_map:

EXTERN __COPY_IN_RAM
    ;Copio las isr a ram. Push de fuente, destino y tamaño
EXTERN  __ISR_LEN
EXTERN  __ISR_START_ROM  ;Origen
EXTERN  __ISR_START_RAM  ;Destino
    push __ISR_START_ROM    
    push __ISR_START_RAM
    push __ISR_LEN
  	call __COPY_IN_RAM
    times 3 pop eax

    ;Copio las sys tables a ram
EXTERN  __SYS_TABLES_RAM
EXTERN  __SYS_TABLES_ROM
EXTERN  __SYS_TABLES_LEN
  push __SYS_TABLES_ROM
  push __SYS_TABLES_RAM
  push __SYS_TABLES_LEN
  call __COPY_IN_RAM
  times 3 pop eax

    ;Voy a llamar a copy para copiar las rutinas. Pusheo fuente, destino y tamaño.
EXTERN  __ROUTINES_LEN
EXTERN  __ROUTINES_START_ROM  ;Origen
EXTERN  __ROUTINES_START_RAM  ;Destino
    push __ROUTINES_START_ROM    
    push __ROUTINES_START_RAM
    push __ROUTINES_LEN
    call __COPY_IN_RAM           
    times 3 pop eax

    ;Copio el nucleo a nucleo. Push de fuente, destino y tamaño
EXTERN __KERNEL_START_RAM
EXTERN __KERNEL_START_ROM
EXTERN __KERNEL_LEN
  push __KERNEL_START_ROM
  push __KERNEL_START_RAM
  push __KERNEL_LEN
  call __COPY_IN_RAM
  times 3 pop eax

	;Copio la seccion de datos inicializados (.datos)
EXTERN 	__DATOS_START_RAM
EXTERN  __DATOS_START_ROM 
EXTERN 	__DATOS_LEN
	push __DATOS_START_ROM
	push __DATOS_START_RAM
	push __DATOS_LEN
	call __COPY_IN_RAM
	times 3 pop eax


;**********************************************;Fin de copiado;***********************************************;

;Inicializo en 0 las variables de .bss
EXTERN __BSS_LEN
EXTERN __BSS_START
  xor eax,eax
  mov ebx, __BSS_START
  mov ecx, __BSS_LEN
    shr ecx,2
  init_bss_loop:
    mov [ebx],eax
    add ebx,4
    loop init_bss_loop

ret




;******************************COPIO TASK1 A RAM***************************************;

GLOBAL init_ram_task1
init_ram_task1:

;Copio la tarea 1 a ram
EXTERN  __TASK1_TEXT_START_ROM 
EXTERN  __TASK1_TEXT_START_RAM
EXTERN 	__TASK1_TEXT_LEN
	push __TASK1_TEXT_START_ROM
	push __TASK1_TEXT_START_RAM
	push __TASK1_TEXT_LEN
	call __COPY_IN_RAM
	times 3 pop eax

EXTERN  __TASK1_BSS_START_ROM 
EXTERN  __TASK1_BSS_START_RAM
EXTERN  __TASK1_BSS_LEN
  push __TASK1_BSS_START_ROM
  push __TASK1_BSS_START_RAM
  push __TASK1_BSS_LEN
  call __COPY_IN_RAM
  times 3 pop eax
  
EXTERN  __TASK1_DATA_START_ROM 
EXTERN  __TASK1_DATA_START_RAM
EXTERN  __TASK1_DATA_LEN
  push __TASK1_DATA_START_ROM
  push __TASK1_DATA_START_RAM
  push __TASK1_DATA_LEN
  call __COPY_IN_RAM 					
  times 3 pop eax

;Inicializo en 0 las variables de .task1_BSS
EXTERN __TASK1_BSS_LEN
EXTERN __TASK1_BSS_START_RAM
  xor eax,eax
  mov ebx, __TASK1_BSS_START_RAM
  mov ecx, __TASK1_BSS_LEN
  shr ecx,2
  init_task1_bss_loop:
    mov [ebx],eax
    add ebx,4
    loop init_task1_bss_loop
    
ret


;******************************COPIO TASK2 A RAM***************************************;

GLOBAL init_ram_task2
init_ram_task2:

;Copio la tarea 2 a ram
EXTERN  __TASK2_TEXT_START_ROM 
EXTERN  __TASK2_TEXT_START_RAM
EXTERN  __TASK2_TEXT_LEN
  push __TASK2_TEXT_START_ROM
  push __TASK2_TEXT_START_RAM
  push __TASK2_TEXT_LEN
  call __COPY_IN_RAM
  times 3 pop eax

EXTERN  __TASK2_BSS_START_ROM 
EXTERN  __TASK2_BSS_START_RAM
EXTERN  __TASK2_BSS_LEN
  push __TASK2_BSS_START_ROM
  push __TASK2_BSS_START_RAM
  push __TASK2_BSS_LEN
  call __COPY_IN_RAM
  times 3 pop eax
  
EXTERN  __TASK2_DATA_START_ROM 
EXTERN  __TASK2_DATA_START_RAM
EXTERN  __TASK2_DATA_LEN
  push __TASK2_DATA_START_ROM
  push __TASK2_DATA_START_RAM
  push __TASK2_DATA_LEN
  call __COPY_IN_RAM          
  times 3 pop eax

;Inicializo en 0 las variables de .task2_BSS
EXTERN __TASK2_BSS_LEN
EXTERN __TASK2_BSS_START_RAM
  xor eax,eax
  mov ebx, __TASK2_BSS_START_RAM
  mov ecx, __TASK2_BSS_LEN
  shr ecx,2
  init_task2_bss_loop:
    mov [ebx],eax
    add ebx,4
    loop init_task2_bss_loop
    
ret


;******************************COPIO TASK2 A RAM***************************************;

GLOBAL init_ram_task0
init_ram_task0:

;Copio la tarea 1 a ram
EXTERN  __TASK0_TEXT_START_ROM 
EXTERN  __TASK0_TEXT_START_RAM
EXTERN  __TASK0_TEXT_LEN
  push __TASK0_TEXT_START_ROM
  push __TASK0_TEXT_START_RAM
  push __TASK0_TEXT_LEN
  call __COPY_IN_RAM
  times 3 pop eax
  
ret
