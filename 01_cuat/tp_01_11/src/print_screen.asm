%define BREAKPOINT	xchg bx,bx

TEXT_COLOR		equ	0x04
NUMBER_COLOR	equ	0x1E
SCREEN_WIDTH	equ	160
MSG_ROW 		equ SCREEN_WIDTH*5
MSG_COL			equ 2*1					;el dos indica que utiliza 2 bytes por espacio (caracter y atributos)

HEXA_PREFIX_ROW		equ	SCREEN_WIDTH*5
HEXA_PREFIX_COL		equ	2*17

NUMB_ROW		equ	SCREEN_WIDTH*5
NUMB_COL		equ	2*20

GLOBAL	print_screen

EXTERN 	__VIDEO_BUFFER_START
EXTERN	acum_sum

section .screen_routines

texto:
	dw MSG_ROW+MSG_COL
    db "Suma acumulada:",0

text_hexa_prefix:
	dw HEXA_PREFIX_COL+HEXA_PREFIX_ROW
	db "0x ",0



print_screen:	
    mov ebx,__VIDEO_BUFFER_START 		
    mov ecx,2000						;Cantidad de caracteres que entran en la pantala
    mov ax,0720h						;' ' en hexa + atributos

	.bucle_cls:
		mov [ebx],ax
		add ebx,2
		loop .bucle_cls

	lea edx,[texto] 				;cargo el texto 
	push edx						;pusheo dirección de inicio del texto
	push dword TEXT_COLOR			;pusheo el color del texto
	call show_text
	pop eax
	pop eax 					

	lea edx,[text_hexa_prefix]		;cargo el texto 
	push edx						;pusheo dirección de inicio del texto
	push dword NUMBER_COLOR			;pusheo el color del texto
	call show_text
	pop eax
	pop eax 

	show_acum_sum:
		mov edi, NUMB_COL+NUMB_ROW	;cargo la posición en la pantalla del numero a mostrar
		add	edi, __VIDEO_BUFFER_START 	;ubico esa posición en memoria de video
		mov ecx, 0x8				;Recorrer un quad word, 8 bytes
		mov esi, acum_sum+7			;Empiezo por el byte más significativo del acumulador
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