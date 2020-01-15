%define BREAKPOINT	xchg bx,bx

%define	page_att 	[ebp+4]
%define	page_table_att 	[ebp+8]
%define	sect_len	 	[ebp+12]
%define	phy_addr	 	[ebp+16]
%define lin_addr		[ebp+20]
%define page_table_addr	[ebp+24]

__DIR_PAGE_ATT_USER_RW			EQU	0x3
__PAGE_TABLE_ATT_USER_RW		EQU	0x3


EXTERN	__PAGE_DIRECTORY_ADDR
EXTERN  __PAGE_TABLES_QTY


section	.pagination_routines

;***************************************************************************************************;
;__paginate: Función que pagina una sección. Recibe:                                  				;
;1_Dirección de la tabla de página                                                   				;
;2_Dirección lineal de la sección                                                   				;
;3_Dirección física de la sección                                                    				;
;4_Longitud de la sección (para calcular la cantidad de páginas que se necesitan)     				;
;5_Atributos de la tabla de página                                                    				;
;6_Atributos de la página                                                    						;
;No hace falta la dirección del directorio de página ya que es el mismo para todo (CREO o POR AHORA);
;***************************************************************************************************;
GLOBAL 	__paginate
__paginate:
	mov ebp,esp
	mov eax, lin_addr		; Cargo la dirección lineal en el acumulador
	shr eax, 22				; Shifteo por 22 para quedarme con los últimos 10 bits más significativos (índice del directorio)
	shl eax, 2 				; Shifteo por 2 para multiplicar por 4, (cada entrada son 4 Bytes)
	add eax, __PAGE_DIRECTORY_ADDR 	; Le sumo la dirección del directorio de paginación y lo giardo en EDI
	mov edi,eax
	mov eax, page_table_addr 	; Cargo en el acumulador la dirección de la tabla de página
	add eax, page_table_att 	; Le sumo los atributos de la tabla
	mov [edi], eax 				; Cargo en el directorio la información de la tabla (dir + att)

	mov eax, lin_addr 			; Cargo en el acumulador la dirección lineal 
	shr	eax, 12 				; Shifteo 12 y hago una and con 0x3FF para quedarme con los 10 bits del índice de tabla
	and eax, 0x3FF
	shl eax, 2 					; Multiplico por 4 ya que cada entrada son 4 Bytes
	add eax, page_table_addr 	; Le sumo la dirección de la tabla de página y lo muevo a EDI
	mov edi, eax 	 
	mov eax, phy_addr 			; Cargo en el acumulador la dirección física
	add eax, page_att 			; Le sumo los atributos de la página
	mov ecx, sect_len 			; Cargo en ECX la longitud de la sección
	loop_paginate:
		mov [edi], eax 			; Cargo en la tabla la info de la pag (dir fisica y att)
		add edi, 4 				; Apunto a la siguiente entrada
		add eax, 0x1000 		; Apunto a la siguiente dirección de memoria a paginar (los siguientes 4kb)
		sub ecx, 0x1000 		; Le resto al "contador" 4kb, 
		jg loop_paginate		; Si la resta dio positiva, pagino los siguientes 4kb
	ret
	

section	.init_RAM

;************************************************************************************ ;
;__paginate: Función que pagina una sección. Recibe:                                  ;
;1_Dirección de la tabla de página                                                    ;
;2_Dirección lineal de la sección                                                     ;
;3_Dirección física de la sección                                                     ;
;4_Longitud de la sección (para calcular la cantidad de páginas que se necesitan)     ;
;5_Atributos de la tabla de página                                                    ;
;6_Atributos de la página                                                             ;
;*************************************************************************************;
GLOBAL	page_memory
page_memory:
; Limpio el Directorio y las Tablas de paginación
EXTERN  __PAGE_DIRECTORY_ADDR
EXTERN  __PAGE_TABLE_0x000_ADDR
EXTERN  __PAGE_TABLE_0x001_ADDR
EXTERN  __PAGE_TABLE_0x07F_ADDR
EXTERN  __PAGE_TABLE_0x3FF_ADDR
EXTERN  __PAGE_TABLES_SIZE
    mov edi, __PAGE_DIRECTORY_ADDR
    mov ecx, __PAGE_TABLES_SIZE
    shr ecx, 2
    xor eax, eax
  .ciclo_ini_dir_pag:
      mov [edi], eax
      add edi, 4
      dec ecx
      jnz .ciclo_ini_dir_pag

; Comienzo la paginación

;Paginación de .init
;Dirección lineal:  0xFFFF0000  
; 0x 1111 1111 11|11 1111 0000 | 0x0 0x0 0x0 
;   3 F   F  | 3  F   0   
;Indice de directorio : 0x3FF
;Indice de tabla:     0x3F0 / 0x3F1 
;Tamaño de la sección: 0x1405 Bytes ==> 2 páginas
EXTERN  __PAGE_TABLE_0x3FF_ADDR
EXTERN  __INIT_LINEAR_ADDR
EXTERN  __INIT_LEN
EXTERN  __INIT_PHYSICAL_ADDR
    push __PAGE_TABLE_0x3FF_ADDR
    push __INIT_LINEAR_ADDR
    push __INIT_PHYSICAL_ADDR
    push __INIT_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax


;Paginación de .isr
;Dirección física: 0x00000000
;Dirección lineal: 0x00000000
; 0x 0000 0000 00|00 0000 0000 | 0x0 0x0 0x0
;   0 0 0  | 0  0 0 
;Indice de directorio : 0x000
;Indice de tabla:     0x000
;Tamaño de la sección: 0xC9 Bytes ==> 1 página
EXTERN  __ISR_LINEAR_ADDR
EXTERN  __ISR_PHYSICAL_ADDR
EXTERN  __ISR_LEN
    push __PAGE_TABLE_0x000_ADDR
    push __ISR_LINEAR_ADDR
    push __ISR_PHYSICAL_ADDR
    push __ISR_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax


;Paginación del buffer de video
;Dirección física: 0x000B8000
;Dirección lineal: 0x00010000
; 0x 0000 0000 00|00 0001 0000 | 0x0 0x0 0x0
;   	0 	0 	0| 0	1	0   
;Indice de directorio : 0x000
;Indice de tabla:     0x10 / 0x11 / 0x12 / 0x13 / 0x14 / 0x15 / 0x16 / 0x17
;Tamaño de la sección: 0x7FFF Bytes ==> 8 páginas
EXTERN  __VIDEO_BUFFER_LINEAR_ADDR
EXTERN  __VIDEO_BUFFER_PHYSICAL_ADDR
EXTERN  __VIDEO_BUFFER_LEN
    push __PAGE_TABLE_0x000_ADDR
    push __VIDEO_BUFFER_LINEAR_ADDR
    push __VIDEO_BUFFER_PHYSICAL_ADDR
    push __VIDEO_BUFFER_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax


;Paginación de SysTables
;Dirección lineal: 0x00100000
;Dirección física: 0x00100000
; 0x 0000 0000 00|01 0000 0000 | 0x0 0x0 0x0
;   	0 0 	0| 1  0 	0 
;Indice de directorio : 0x000
;Indice de tabla:     0x100
;Tamaño de la sección: 0xC9 Bytes ==> 1 página

EXTERN  __SYS_TABLES_LINEAR_ADDR
EXTERN  __SYS_TABLES_PHYSICAL_ADDR
EXTERN  __SYS_TABLES_LEN
    push __PAGE_TABLE_0x000_ADDR
    push __SYS_TABLES_LINEAR_ADDR
    push __SYS_TABLES_PHYSICAL_ADDR
    push __SYS_TABLES_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax



;Paginación de PageTables
;Dirección lineal: 0x00110000
;Dirección física: 0x00110000
; 0x 0000 0000 00|01 0001 0000 | 0x0 0x0 0x0
;   	0 0 	0| 1  1 	0 
;Indice de directorio : 0x000
;Indice de tabla:     0x110
;Tamaño de la sección: __PAGE_TABLES_SIZE (5*0x1000 = 20kB) ==> 5 páginas
EXTERN  __PAGE_TABLES_LINEAR_ADDR
EXTERN  __PAGE_TABLES_PHYISICAL_ADDR
EXTERN  __PAGE_TABLES_SIZE
    push __PAGE_TABLE_0x000_ADDR
    push __PAGE_TABLES_LINEAR_ADDR
    push __PAGE_TABLES_PHYISICAL_ADDR
    push __PAGE_TABLES_SIZE
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax



;Paginación de copy
;Dirección lineal: 0x00200000
;Dirección física: 0x00200000
; 0x 0000 0000 00|02 0000 0000 | 0x0 0x0 0x0
;         0 0 0  | 2 0      0   
;Indice de directorio : 0x000
;Indice de tabla:       0x200
;Tamaño de la sección: 0x15 Bytes ==> 1 página
EXTERN  __COPY_LINEAR_ADDR
EXTERN  __COPY_PHYSICAL_ADDR
EXTERN  __COPY_LEN
    push __PAGE_TABLE_0x000_ADDR
    push __COPY_LINEAR_ADDR
    push __COPY_PHYSICAL_ADDR
    push __COPY_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax

;Paginación de routines
;Dirección lineal: 0x00210000
;Dirección física: 0x00210000
; 0x 0000 0000 00|10 0001 0000 | 0x0 0x0 0x0
;         0 0 0  | 2 1      0   
;Indice de directorio : 0x000
;Indice de tabla:       0x210
;Tamaño de la sección: 0x3b6 Bytes ==> 1 página
EXTERN  __ROUTINES_LINEAR_ADDR
EXTERN  __ROUTINES_PHYSICAL_ADDR
EXTERN  __ROUTINES_LEN
    push __PAGE_TABLE_0x000_ADDR
    push __ROUTINES_LINEAR_ADDR
    push __ROUTINES_PHYSICAL_ADDR
    push __ROUTINES_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax


;Paginación de init_RAM
;Dirección lineal: 0x00220000
;Dirección fisica: 0x00220000
; 0x 0000 0000 00|10 0010 0000 | 0x0 0x0 0x0
;         0 0 0  | 2  2     0   
;Indice de directorio : 0x000
;Indice de tabla:       0x220
;Tamaño de la sección: 0x23B Bytes ==> 1 página
EXTERN  __INIT_RAM_LINEAR_ADDR
EXTERN  __INIT_RAM_PHYSICAL_ADDR
EXTERN  __INIT_RAM_LEN
    push __PAGE_TABLE_0x000_ADDR
    push __INIT_RAM_LINEAR_ADDR
    push __INIT_RAM_PHYSICAL_ADDR
    push __INIT_RAM_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax


;Paginación de kernel
;Dirección física: 0x00400000
;Dirección lineal: 0x00400000
; 0x 0000 0000 01|00 0000 0000 | 0x0 0x0 0x0
;         0 0 1  | 0  0     0   
;Indice de directorio : 0x001
;Indice de tabla:       0x000
;Tamaño de la sección: 0x35 Bytes ==> 1 página
EXTERN  __KERNEL_LINEAR_ADDR
EXTERN  __KERNEL_PHYSICAL_ADDR
EXTERN  __KERNEL_LEN
    push __PAGE_TABLE_0x001_ADDR
    push __KERNEL_LINEAR_ADDR
    push __KERNEL_PHYSICAL_ADDR
    push __KERNEL_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax

;Paginación de la digit table
;Dirección física: 0x00410000
;Dirección lineal: 0x00410000
; 0x 0000 0000 01|00 0001 0000 | 0x0 0x0 0x0
;         0 0 1  | 0  1     0   
;Indice de directorio : 0x001
;Indice de tabla:       0x010
;Tamaño de la sección: 0xffff Bytes ==> 16 páginas
EXTERN  __DIGIT_TABLE_LINEAR_ADDR
EXTERN  __DIGIT_TABLE_PHYSICAL_ADDR
EXTERN  __DIGIT_TABLE_SIZE
    push __PAGE_TABLE_0x000_ADDR
    push __DIGIT_TABLE_LINEAR_ADDR
    push __DIGIT_TABLE_PHYSICAL_ADDR
    push __DIGIT_TABLE_SIZE
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax

;Paginación de task_TEXT
;Dirección física: 0x00420000
;Dirección lineal: 0x00510000
; 0x 0000 0000 01|01 0001 0000 | 0x0 0x0 0x0
;         0 0 1  | 1  1     0   
;Indice de directorio : 0x001
;Indice de tabla:       0x0110
;Tamaño de la sección: 0x3C Bytes ==> 1 página
EXTERN  __TASK1_TEXT_LINEAR_ADDR
EXTERN  __TASK1_TEXT_PHYSICAL_ADDR
EXTERN  __TASK1_TEXT_LEN
    push __PAGE_TABLE_0x001_ADDR
    push __TASK1_TEXT_LINEAR_ADDR
    push __TASK1_TEXT_PHYSICAL_ADDR
    push __TASK1_TEXT_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax


;Paginación de task_BSS
;Dirección física: 0x00421000
;Dirección lineal: 0x00511000
; 0x 0000 0000 01|01 0001 0001 | 0x0 0x0 0x0
;         0 0 1  | 1  1     1   
;Indice de directorio : 0x001
;Indice de tabla:       0x111
;Tamaño de la sección: 0x9 Bytes ==> 1 página
EXTERN  __TASK1_BSS_LINEAR_ADDR
EXTERN  __TASK1_BSS_PHYSICAL_ADDR
EXTERN  __TASK1_BSS_LEN
    push __PAGE_TABLE_0x001_ADDR
    push __TASK1_BSS_LINEAR_ADDR
    push __TASK1_BSS_PHYSICAL_ADDR
    push __TASK1_BSS_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax


;Paginación de task_DATA
;Dirección física: 0x00422000
;Dirección lineal: 0x00512000
; 0x 0000 0000 01|01 0001 0002 | 0x0 0x0 0x0
;         0 0 1  | 1  1     2   
;Indice de directorio : 0x001
;Indice de tabla:       0x022
;Tamaño de la sección: 0x9 Bytes ==> 1 página
EXTERN  __TASK1_DATA_LINEAR_ADDR
EXTERN  __TASK1_DATA_PHYSICAL_ADDR
EXTERN  __TASK1_DATA_LEN
    push __PAGE_TABLE_0x001_ADDR
    push __TASK1_DATA_LINEAR_ADDR
    push __TASK1_DATA_PHYSICAL_ADDR
    push __TASK1_DATA_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax


;Paginación de datos
;Dirección física: 0x004E0000
;Dirección lineal: 0x004E0000
; 0x 0000 0000 01|00 1110 0000 | 0x0 0x0 0x0
;         0 0 1  | 0  E     0   
;Indice de directorio : 0x001
;Indice de tabla:       0x0E0
;Tamaño de la sección: 0x0 Bytes ==> 1 página
EXTERN  __DATA_LINEAR_ADDR
EXTERN  __DATA_PHYSICAL_ADDR
EXTERN  __DATOS_LEN
    push __PAGE_TABLE_0x001_ADDR
    push __DATA_LINEAR_ADDR
    push __DATA_PHYSICAL_ADDR
    push __DATOS_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax


;Paginación de BSS
;Dirección física: 0x004F0000
;Dirección lineal: 0x004F0000
; 0x 0000 0000 01|00 1111 0000 | 0x0 0x0 0x0
;         0 0 1  | 0  F     0   
;Indice de directorio : 0x001
;Indice de tabla:       0x0F0
;Tamaño de la sección: 0x36 Bytes ==> 1 página
EXTERN  __BSS_LINEAR_ADDR
EXTERN  __BSS_PHYSICAL_ADDR
EXTERN  __BSS_LEN
    push __PAGE_TABLE_0x001_ADDR
    push __BSS_LINEAR_ADDR
    push __BSS_PHYSICAL_ADDR
    push __BSS_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax

;Paginación de STACK
;Dirección física: 0x1FFFB000
;Dirección lineal: 0x1FFFB000
; 0x 0001 1111 11|11 1111 1011 | 0x0 0x0 0x0
;         0 7 F  | 3  F     B   
;Indice de directorio : 0x07F
;Indice de tabla:       0x3FB
;Tamaño de la sección: 0x3000 Bytes ==> 3 páginas
EXTERN  __STACK_LINEAR_ADDR
EXTERN  __STACK_PHYSICAL_ADDR
EXTERN  __STACK_SIZE
    push __PAGE_TABLE_0x07F_ADDR
    push __STACK_LINEAR_ADDR
    push __STACK_PHYSICAL_ADDR
    push __STACK_SIZE
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax


;Paginación de TASK1_STACK
;Dirección física: 0x1FFFE000
;Dirección lineal: 0x00413000
; 0x 0000 0000 01|00 0001 0011 | 0x0 0x0 0x0
;         0 0 1  | 0  1     3   
;Indice de directorio : 0x001
;Indice de tabla:       0x013
;Tamaño de la sección: 0x2000 Bytes ==> 2 página
EXTERN  __TASK1_STACK_LINEAR_ADDR
EXTERN  __TASK1_STACK_PHYSICAL_ADDR
EXTERN  __TASK1_STACK_SIZE
    push __PAGE_TABLE_0x001_ADDR
    push __TASK1_STACK_LINEAR_ADDR
    push __TASK1_STACK_PHYSICAL_ADDR
    push __TASK1_STACK_SIZE
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax


;Paginación de RESET
;Dirección física: 0xFFFFFFF0
;Dirección lineal: 0xFFFFFFF0
; 0x 1111 1111 11|11 1111 1111 | 0xF 0xF 0x0
;       3  F  F  | 3  F     F   
;Indice de directorio : 0x3FF
;Indice de tabla:       0x3FF
;Tamaño de la sección: 0x10 Bytes ==> 1 página
EXTERN  __RESET_LINEAR_ADDR
EXTERN  __RESET_PHYSICAL_ADDR
EXTERN  __RESET_LEN
    push __PAGE_TABLE_0x3FF_ADDR
    push __RESET_LINEAR_ADDR
    push __RESET_PHYSICAL_ADDR
    push __RESET_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax

	ret








EXTERN  __PAGE_TABLES_QTY_FIX
EXTERN  __PHYSICAL_ADDR_NEW_PAGES

GLOBAL  __page_missing_page

__page_missing_page:
BREAKPOINT
    mov ebx, [esp+4]        ;Cargo la dirección lineal que produjo el #PF
    shr ebx, 22             ; Shifteo por 22 para quedarme con los últimos 10 bits más significativos (índice del directorio)
    shl ebx, 2              ; Shifteo por 2 para multiplicar por 4, (cada entrada son 4 Bytes)
    add ebx, __PAGE_DIRECTORY_ADDR  ; Le sumo la dirección del directorio de paginación y lo guardo en EDI

    cmp dword [ebx],0                       ; Si esa entrada del directorio es 0, hay que crear la tabla de página
    jnz .page_table_present
        inc dword [new_page_tables_counter] ; Incremento el contador de páginas "dinámicas"
        mov eax, __PAGE_TABLES_QTY_FIX      ; Cargo la cantidad de páginas fijas
        shl eax, 12                         ; Lo multiplico por 0x1000 (no me deja hacer la multiplicación convencional)
        add eax, __PAGE_DIRECTORY_ADDR      ; Le sumo la dirección del directorio de páginas
        mov edx, [new_page_tables_counter]  ; Cantidad de páginas "dinámicas" creadas
        shl edx, 12                         ; Tamaño de esas páginas creadas
        add eax, edx                        ; Dirección de la nueva tabla de página a crear
        mov edx, __DIR_PAGE_ATT_USER_RW     ; Cargo en EDX atributos de rw y usuario
        add edx, eax
        mov [ebx], edx                      ; Cargo en el índice del directorio la dirección de la tabla + ATTR

        ;Limpio la página creada
        mov edi, eax                        ;Cargo en EDI la dirección de la nueva página (para no tocar EAX)
        mov ecx, 0x400                      ;Tamaño de la página
       .ciclo_ini_dir_pag:
          mov dword [edi], 0                ;Relleno con 0s
          add edi, 4
          loop .ciclo_ini_dir_pag
    
        mov ebx, [esp+4]            ; Vuelvo a cargar la dirección lineal
        shr ebx, 12                 ; Shifteo 12 y hago una and con 0x3FF para quedarme con los 10 bits del índice de tabla
        and ebx, 0x3FF
        shl ebx, 2                  ; Multiplico por 4 ya que cada entrada son 4 Bytes
        add ebx, eax                ; Le sumo la dirección de la tabla de página
        mov eax, [new_pages_counter]            ; Cargo en el acumulador la cantidad de páginas creadas
        shl eax, 12                             ; La multiplico por 0x1000
        add eax, __PHYSICAL_ADDR_NEW_PAGES      ; Le sumo la dirección física base
        add eax, __PAGE_TABLE_ATT_USER_RW       ; Le sumo los atributos de la página
        mov [ebx], eax
        inc byte [new_pages_counter]            ; Incremento la cantidad de páginas creadas
        jmp .exit

    .page_table_present:    ; Si la tabla está presente
    mov edx, [ebx]         ; Cargo en eax el contenido del índice de directorio
    and edx, 0xFFFFF000    ; Me deshago de los bits de ATTR
    mov ebx, [esp+4]            ; Vuelvo a cargar la dirección lineal
    shr ebx, 12                 ; Shifteo 12 y hago una and con 0x3FF para quedarme con los 10 bits del índice de tabla
    and ebx, 0x3FF
    shl ebx, 2                  ; Multiplico por 4 ya que cada entrada son 4 Bytes
    add ebx, edx                ; Le sumo la dirección de la tabla de página
    mov eax, [new_pages_counter]      ; Cargo en el acumulador la cantidad de páginas creadas
    shl eax, 12                             ; La multiplico por 0x1000
    add eax, __PHYSICAL_ADDR_NEW_PAGES      ; Le sumo la dirección física base
    add eax, __PAGE_TABLE_ATT_USER_RW       ; Le sumo los atributos de la página
    mov [ebx], eax
    inc byte [new_pages_counter]            ; Incremento la cantidad de páginas creadas

.exit:
ret



GLOBAL  new_page_tables_counter
GLOBAL  new_pages_counter

section .bss nobits

new_page_tables_counter     resd  0x1
new_pages_counter           resd  0x1