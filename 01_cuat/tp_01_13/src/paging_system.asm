%define BREAKPOINT	xchg bx,bx

%define	page_att 	[ebp+4]
%define	page_table_att 	[ebp+8]
%define	sect_len	 	[ebp+12]
%define	phy_addr	 	[ebp+16]
%define lin_addr		[ebp+20]
%define page_table_addr	[ebp+24]
%define pag_dir_addr    [ebp+28]

__DIR_PAGE_ATT_USER_RW			EQU	0x3
__PAGE_TABLE_ATT_USER_RW		EQU	0x3


EXTERN	__PAGE_DIRECTORY_ADDR_TASK0
EXTERN  __PAGE_TABLES_QTY


section	.pagination_routines

;***************************************************************************************************;
;__paginate: Función que pagina una sección. Recibe: 
;0_Dirección del directorio de página                                                 				;
;1_Dirección de la tabla de página                                                   				;
;2_Dirección lineal de la sección                                                   				;
;3_Dirección física de la sección                                                    				;
;4_Longitud de la sección (para calcular la cantidad de páginas que se necesitan)     				;
;5_Atributos de la tabla de página                                                    				;
;6_Atributos de la página                                                    						;
;***************************************************************************************************;
GLOBAL 	__paginate
__paginate:
	mov ebp,esp
	mov eax, lin_addr		; Cargo la dirección lineal en el acumulador
	shr eax, 22				; Shifteo por 22 para quedarme con los últimos 10 bits más significativos (índice del directorio)
	shl eax, 2 				; Shifteo por 2 para multiplicar por 4, (cada entrada son 4 Bytes)
	add eax, pag_dir_addr 	; Le sumo la dirección del directorio de paginación y lo giardo en EDI
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
	


;**********************************************PAGINACIÓN DE #PF**************************************************;

EXTERN  __PAGE_TABLES_QTY_FIX
EXTERN  __PHYSICAL_ADDR_NEW_PAGES

GLOBAL  __page_missing_page

__page_missing_page:

    mov ebx, [esp+4]        ;Cargo la dirección lineal que produjo el #PF
    shr ebx, 22             ; Shifteo por 22 para quedarme con los últimos 10 bits más significativos (índice del directorio)
    shl ebx, 2              ; Shifteo por 2 para multiplicar por 4, (cada entrada son 4 Bytes)
    add ebx, __PAGE_DIRECTORY_ADDR_TASK0  ; Le sumo la dirección del directorio de paginación y lo guardo en EDI

    cmp dword [ebx],0                       ; Si esa entrada del directorio es 0, hay que crear la tabla de página
    jnz .page_table_present
        inc dword [new_page_tables_counter] ; Incremento el contador de páginas "dinámicas"
        mov eax, __PAGE_TABLES_QTY_FIX      ; Cargo la cantidad de páginas fijas
        shl eax, 12                         ; Lo multiplico por 0x1000 (no me deja hacer la multiplicación convencional)
        add eax, __PAGE_DIRECTORY_ADDR_TASK0      ; Le sumo la dirección del directorio de páginas
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