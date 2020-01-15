%define BREAKPOINT	xchg bx,bx

%define	page_att 	[ebp+4]
%define	page_table_att 	[ebp+8]
%define	sect_len	 	[ebp+12]
%define	phy_addr	 	[ebp+16]
%define lin_addr		[ebp+20]
%define page_table_addr	[ebp+24]

__DIR_PAGE_ATT_USER_RW			EQU	0x3
__PAGE_TABLE_ATT_USER_RW		EQU	0x3

GLOBAL	__DIR_PAGE_ATT_USER_RW
GLOBAL	__PAGE_TABLE_ATT_USER_RW

EXTERN	__PAGE_DIRECTORY_ADDR


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
;Dirección lineal: 0x000B8000
; 0x 0000 0000 00|00 1011 1000 | 0x0 0x0 0x0
;   0 0 0  | 0  B   8 
;Indice de directorio : 0x000
;Indice de tabla:     0xB8 / 0xB9 / 0xBA / 0xBB / 0xBC / 0xBD / 0xBE / 0xBF
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
; 0x 0000 0000 00|01 0000 0000 | 0x0 0x0 0x0
;   0 0 0  | 1  0 0 
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
; 0x 0000 0000 00|01 1000 0000 | 0x0 0x0 0x0
;   0 0 0  | 1  1 0 
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
;Dirección lineal: 0x003F0000
; 0x 0000 0000 00|11 1111 0000 | 0x0 0x0 0x0
;         0 0 0  | 3  F     0   
;Indice de directorio : 0x000
;Indice de tabla:       0x3F0
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
;Dirección lineal: 0x00410000
; 0x 0000 0000 01|00 0001 0000 | 0x0 0x0 0x0
;         0 0 1  | 0  1     0   
;Indice de directorio : 0x001
;Indice de tabla:       0x010
;Tamaño de la sección: 0xffff Bytes ==> 16 páginas
EXTERN  __DIGIT_TABLE_LINEAR_ADDR
EXTERN  __DIGIT_TABLE_PHYSICAL_ADDR
EXTERN  __DIGIT_TABLE_SIZE
    push __PAGE_TABLE_0x001_ADDR
    push __DIGIT_TABLE_LINEAR_ADDR
    push __DIGIT_TABLE_PHYSICAL_ADDR
    push __DIGIT_TABLE_SIZE
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax

;Paginación de task_TEXT
;Dirección lineal: 0x00420000
; 0x 0000 0000 01|00 0002 0000 | 0x0 0x0 0x0
;         0 0 1  | 0  2     0   
;Indice de directorio : 0x001
;Indice de tabla:       0x020
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
;Dirección lineal: 0x00421000
; 0x 0000 0000 01|00 0002 0001 | 0x0 0x0 0x0
;         0 0 1  | 0  2     1   
;Indice de directorio : 0x001
;Indice de tabla:       0x021
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
;Dirección lineal: 0x00422000
; 0x 0000 0000 01|00 0002 0002 | 0x0 0x0 0x0
;         0 0 1  | 0  2     2   
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

;Paginación de BSS
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
;Dirección lineal: 0x1FFFE000
; 0x 0001 1111 11|11 1111 1110 | 0x0 0x0 0x0
;         0 7 F  | 3  F     E   
;Indice de directorio : 0x07F
;Indice de tabla:       0x3FE
;Tamaño de la sección: 0x1000 Bytes ==> 1 página
EXTERN  __TASK1_STACK_LINEAR_ADDR
EXTERN  __TASK1_STACK_PHYSICAL_ADDR
EXTERN  __TASK1_STACK_SIZE
    push __PAGE_TABLE_0x07F_ADDR
    push __TASK1_STACK_LINEAR_ADDR
    push __TASK1_STACK_PHYSICAL_ADDR
    push __TASK1_STACK_SIZE
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 6 pop eax


;Paginación de RESET
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