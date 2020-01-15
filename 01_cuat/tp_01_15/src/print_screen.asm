%define BREAKPOINT	xchg bx,bx

TEXT_COLOR		equ	0x0A
NUMBER_COLOR	equ	0x1E
SCREEN_WIDTH	equ	160
MSG_ROW 		equ SCREEN_WIDTH*5
MSG_COL			equ 2*1					;el dos indica que utiliza 2 bytes por espacio (caracter y atributos)

HEXA_PREFIX_ROW		equ	SCREEN_WIDTH*5
HEXA_PREFIX_COL		equ	2*20

NUMB_ROW		equ	SCREEN_WIDTH*5
NUMB_COL		equ	2*23

GLOBAL	print_screen
GLOBAL	print_screen_T1
GLOBAL	print_screen_T2

EXTERN 	__VIDEO_BUFFER_START
EXTERN	acum_sum_T1
EXTERN 	acum_sum_T2

section .screen_routines



clean_screen:
	mov ebx,__VIDEO_BUFFER_START 		
    mov ecx,2000						;Cantidad de caracteres que entran en la pantala
    mov ax,0720h						;' ' en hexa + atributos

	.bucle_cls:
		mov [ebx],ax
		add ebx,2
		loop .bucle_cls
ret

show_text:
	mov edx, [esp+4]				;color del texto
	mov edi, [esp+8]				;dirección de inicio del texto (2bytes de ubicacion  + texto)
    movzx ebx,word [edi] 			;Obtener offset dentro del buffer de video.
    add ebx,__VIDEO_BUFFER_START	;EBX = Direccion donde debe ir el texto en pantalla.
    inc edi

	.bucle_disp:
		inc edi       				;Apuntar al siguiente caracter.
        mov al,[edi]     			;Obtener el proximo caracter a mostrar.
        and al,al       			;Ver si se termino.
        jz short .fin_disp 			;Saltar si es asi.
        mov [ebx],al    			;Mandarlo a pantalla.
        mov byte [ebx+1], dl		;Mandar el atributo de colores
        add ebx,2       			;Apuntar a la siguiente posicion en pantalla.
		jmp .bucle_disp
	.fin_disp:
ret

print_screen:	
	mov ebx,[esp+4]					;cargo la dirección del primer parámetro (texto)
	lea edx,[ebx] 					;cargo el texto 
	push edx						;pusheo dirección de inicio del texto
	push dword TEXT_COLOR			;pusheo el color del texto
	call show_text
	pop eax
	pop eax 					

	mov ebx,[esp+8]					;cargo la dirección del segundo parámetro (prefijo)
	lea edx,[ebx] 					;cargo el texto 
	push edx						;pusheo dirección de inicio del texto
	push NUMBER_COLOR				;pusheo el color del texto
	call show_text
	pop eax
	pop eax 

	.show_acum_sum:
		mov eax, [esp+12]			;cargo número de columna
		add eax, [esp+16]			;le sumo el número de fila
		mov edi, eax	;cargo la posición en la pantalla del numero a mostrar
		add	edi, __VIDEO_BUFFER_START 	;ubico esa posición en memoria de video
		mov ecx, 0x8				;Recorrer un quad word, 8 bytes
		;mov esi, acum_sum_T1+7			;Empiezo por el byte más significativo del acumulador
		mov esi, [esp+20]
		add esi, 7
		.show_number_loop:
			cmp ecx,4				;si estoy en la mitad del numero, pongo un separador para leer más facil
			jnz	.not_put_separator
			inc edi 
			mov word [edi], 0x071E	;pongo el separador (espacio con fondo azul)
			inc edi
			.not_put_separator:
			mov al, [esi] 			;cargo el numero en al (consta de 2 digitos a mostrar)
			mov bl, al 				;copio el numero a bl
			and bl, 0xF0
			shr bl, 4
			add bl, 0x30
			cmp bl, '9'
			jle	.was_digit_h
			add bl, 0x7
			.was_digit_h:			
			mov byte [edi], bl
			inc edi
			mov byte [edi], NUMBER_COLOR
			inc edi
			mov bl, al 				;copio el numero a bl
			and bl, 0x0F
			add bl, 0x30
			cmp bl, '9'
			jle	.was_digit_l
			add bl, 0x7
			.was_digit_l:			
			mov byte [edi], bl
			inc edi
			mov byte [edi], NUMBER_COLOR
			inc edi
			dec esi
		loop .show_number_loop
ret

	

GLOBAL pf_error_text
GLOBAL __print_pf_error

PF_ERR_ROW 		equ 15
PF_ERR_COL		equ 1

pf_error_text:
	dw PF_ERR_COL * 2+ PF_ERR_ROW * SCREEN_WIDTH
	db "Error de paginacion en: 0x",0

__print_pf_error:
	push ebx
	lea edx,[pf_error_text] 		;cargo el texto 
	push edx						;pusheo dirección de inicio del texto
	push dword 0x04					;pusheo el color del texto (Fondo negro, letras rojas)
	call show_text
	pop eax
	pop eax 		

	mov edi, PF_ERR_ROW * SCREEN_WIDTH + 27 *2	;cargo la posición en la pantalla del numero a mostrar
	add	edi, __VIDEO_BUFFER_START 			;ubico esa posición en memoria de video
	mov ecx, 28								;Recorrer un doble word, 4 bytes
	pop ebx
	.loop_show_reg:
		mov eax, ebx
		shr eax, cl
		and eax, 0xF

		add al, 0x30
		cmp al, '9'
		jle	.was_digit_h
		add al, 0x7
		.was_digit_h:			
		mov byte [edi], al
		inc edi
		mov byte [edi], 0x40
		inc edi

		sub ecx, 4
		jl .exit
		jmp .loop_show_reg
	.exit
	ret
