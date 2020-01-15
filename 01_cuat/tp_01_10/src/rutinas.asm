%define	BREAKPOINT	xchg bx,bx

EXTERN 	cs_sel

EXTERN	__ROUTINES_LENGTH
EXTERN	__ROUTINES_START_ROM	;Origen
EXTERN 	__ROUTINES_START_RAM	;Destino


section .keyboard_routines
	
EXTERN	__DIGIT_TABLE_START
EXTERN 	__DIGIT_TABLE_SIZE

S_SCAN_CODE	equ	0x1F
Y_SCAN_CODE equ 0x15
U_SCAN_CODE equ 0x16
I_SCAN_CODE equ 0x17
O_SCAN_CODE equ 0x18
P_SCAN_CODE equ 0x19

KEY0_SCAN_CODE	equ 0x0B
KEY1_SCAN_CODE	equ	0x02
KEY9_SCAN_CODE	equ	0x0A
A_SCAN_CODE	equ 0x1E
B_SCAN_CODE	equ 0x30
C_SCAN_CODE	equ 0x2E
D_SCAN_CODE	equ 0x20
E_SCAN_CODE	equ 0x12
F_SCAN_CODE	equ 0x21

ENTER_KEY_SCAN_CODE	equ	0x1C

__KEYBOARD_BUFFER_LEN	equ	0x20
__KB_ANALYSIS_BUFF_LEN 	equ	0x10

GLOBAL	check_0x60_kb

check_0x60_kb:
	xor al, al
	in al, 0x60 					;consulto el puerto de data de teclado
	cmp al,ENTER_KEY_SCAN_CODE		;si se presionó ENTER, salto a la rutina que analiza el buffer de teclado y guarda la tabla
	jz keyboard_buffer_analysis
	cmp al, S_SCAN_CODE				;comparo el scan code leido con el de la 'S', si es 'S' me voy a halted
	jz .halted_state
	cmp al, Y_SCAN_CODE				;comparo el scan code leido con el de 'Y' para generar un divide error
	jz .Y_pressed	
	cmp al, U_SCAN_CODE				;comparo el scan code leido con el de 'U' para generar un opcode
	jz .U_pressed
	cmp al, I_SCAN_CODE				;comparo el scan code leido con el de 'I'
	jz .I_pressed
	cmp al, O_SCAN_CODE				;comparo el scan code leido con el de 'O' para generar un general protection
	jz .O_pressed
	cmp al, P_SCAN_CODE				;comparo el scan code leido con el de 'P' para generar un page fault
	jz .P_pressed

	bt eax, 0x7						;miro el bit 7 de al y lo pongo en el flag de carry
	jc exit							;si el carry es '1', fue un release de una tecla y vuelvo a consultar por estado

	;guardo en el buffer de teclado
	mov ebx,keyboard_buffer

	xor edx,edx
	mov dl, [keyboard_buffer_index]
	add ebx,edx

	mov [ebx],al
	inc byte [keyboard_buffer_index]
	cmp byte [keyboard_buffer_index],__KEYBOARD_BUFFER_LEN
	jz	.reset_keyboard_buffer_index
	ret
		
	.reset_keyboard_buffer_index:
		mov byte [keyboard_buffer_index],0
		ret

    .halted_state:			
    	hlt
    	ret

    .Y_pressed:				;genero un divide error
    	mov eax, 1			;cargo dividendo
    	mov ecx, 0			;cargo divisor
    	div	ecx
    	jmp exit

    .U_pressed:				;genero un opcode error
    	rsm
    	jmp exit

   	.I_pressed:				;genero una doble falta
   		xchg bx,bx			;genero un divide error
   		mov eax, 1			;cargo dividendo
    	mov ecx, 0			;cargo divisor
    	div	ecx
   		jmp exit

   	.O_pressed:				;genero una excepcion de proteccion general
   		mov ax,cs_sel	
   		mov ss,ax
   		jmp exit

   	.P_pressed:
   		jmp 0x30000000		;genero una excepción de page fault
   		jmp exit

exit:
	ret
	    

keyboard_buffer_analysis:

	mov ecx, __KEYBOARD_BUFFER_LEN			;guardo en la longitud del buffer de teclado para un loop
	;mov ecx, [keyboard_buffer_index]
	mov edx, kb_analysis_buffer 			;guardo la dirección del buffer auxiliar
	mov edi, kb_analysis_buffer_index 		;guardo el indice del buffer auxiliar en el que estoy escribiendo
	mov esi, keyboard_buffer_index 			;guardo el indice del buffer de teclado en el que se va a escribir 
	mov ebx, keyboard_buffer

	xor eax,eax
	mov al, [edi]
	add edx, eax

	xor eax,eax
	mov al, [esi]
	add ebx, eax

	.loop_kb_buff_analysis:
		cmp byte [esi], __KEYBOARD_BUFFER_LEN
		jz .resize_index

		.not_resize:
		cmp byte [ebx], A_SCAN_CODE
		jz	.is_A
		cmp byte [ebx], B_SCAN_CODE
		jz	.is_B
		cmp byte [ebx], C_SCAN_CODE
		jz	.is_C
		cmp byte [ebx], D_SCAN_CODE
		jz	.is_D
		cmp byte [ebx], E_SCAN_CODE
		jz	.is_E
		cmp byte [ebx], F_SCAN_CODE
		jz	.is_F
		cmp byte [ebx], KEY0_SCAN_CODE
		jz	.is_0
		cmp byte [ebx], KEY9_SCAN_CODE
		jle .check_greater_KEY1

		inc ebx
		inc byte [esi]

		
		.continue:
		loop .loop_kb_buff_analysis
		
		jmp analysis_buffer_to_digit_table

	.is_A:
		mov byte [edx], 0xA
		jmp .incrementation


	.is_B:
		mov byte [edx], 0xB
		jmp .incrementation

	.is_C:
		mov byte [edx], 0xC
		jmp .incrementation

	.is_D:
		mov byte [edx], 0xD
		jmp .incrementation

	.is_E:
		mov byte [edx], 0xE
		jmp .incrementation

	.is_F:
		mov byte [edx], 0xF
		jmp .incrementation
	.is_0:
		mov byte [edx], 0x0
		jmp .incrementation

	.incrementation:
		inc byte [edi]
		inc byte [esi]
		cmp byte [edi], __KB_ANALYSIS_BUFF_LEN
		jz	.reset_kb_analysis_buff_index
		inc edx
		inc ebx
		inc byte [kb_analysis_buffer_qty]
		jmp .continue

	.resize_index:
		mov byte [esi], 0
		mov ebx, keyboard_buffer
		jmp .not_resize

	.check_greater_KEY1:
		cmp byte [ebx], KEY1_SCAN_CODE
		jge .is_digit

		inc ebx
		inc byte [esi]
		jmp .continue

	.is_digit:
		xor eax,eax
		mov al,[ebx]
		dec al
		mov byte [edx], al
		jmp .incrementation

	
	.reset_kb_analysis_buff_index:
		mov byte [edi],0
		mov edx, kb_analysis_buffer
		inc ebx
		inc byte [kb_analysis_buffer_qty]
		jmp .continue


EXTERN new_number_flag


analysis_buffer_to_digit_table:
	
	;Checkeo si el buffer está vacío. Me ahorro problemas
	push eax
	call is_empty		;si el buffer auxiliar está vacío, se activa el ZF
	pop eax
	jz .exit

	;Situación de borde: si el índice del buffer de lectura (source) es el primer elemento
	mov esi, kb_analysis_buffer_index
	cmp byte [esi],0
	jnz .not_border_situation
	mov byte [edi], __KB_ANALYSIS_BUFF_LEN

	.not_border_situation:
	xor ecx,ecx
	mov cl,__KB_ANALYSIS_BUFF_LEN
	shr ecx,1

	mov al, [esi]
	mov ebx, kb_analysis_buffer
	add ebx, eax
	dec ebx

	mov edi, digit_table_index
	mov ax, [edi]
	mov edx, __DIGIT_TABLE_START
	add edx, eax

	cmp byte [kb_analysis_buffer_qty],1
	jz .odd_entrance

	.loop_analysis_buffer_to_digit_table:
		xor eax,eax
		mov al,[ebx-1]					;agarro el elemento anterior al que estoy apuntando
		shl eax,4						;shift 1 nible y queda en la parte alta
		or eax,[ebx]					;guardo parte alta y parte baja que es EBX
		mov [edx],al 					;guardo el dato
		sub ebx,0x2
		inc edx
		cmp ebx, kb_analysis_buffer 	;checkeo que no me haya pasado del inicio del vector auxiliar
		jle .kb_bf_index_overflow
		.return_kb_bf_index_overflow:
		loop .loop_analysis_buffer_to_digit_table
	
	;Checkeo si la cantidad de elementos ingresados fueron impares
	mov al, [esi]
	bt ax,0
	jc .odd_entrance

	.index_refresh:						;actualizo lo índices
	add dword [digit_table_index],0x8
	mov eax,__DIGIT_TABLE_SIZE
	cmp eax,[digit_table_index] 		;checkeo que no haya habido desborde en los indices
	jz .reset_digit_table_index

	.clean_buffers: 					;limpio los buffers e índices que correspondan
	mov byte [keyboard_buffer_index],0
	mov byte [kb_analysis_buffer_index],0
	mov byte [kb_analysis_buffer_qty],0
	mov ecx, __KEYBOARD_BUFFER_LEN
	mov ebx, keyboard_buffer
	.loop_clear_kb_buff:
		mov byte[ebx],0
		inc ebx
		loop .loop_clear_kb_buff

	mov ecx, __KB_ANALYSIS_BUFF_LEN
	mov ebx, kb_analysis_buffer
	.loop_clear_aux_buff:
		mov byte [ebx],0
		inc ebx
		loop .loop_clear_aux_buff

	mov byte [new_number_flag], 1 					;prendo el flag que indica que se ingreso un nuevo numero
	.exit:
	ret

	.reset_digit_table_index:
    	mov dword [digit_table_index],0
    	jmp .clean_buffers

    .odd_entrance:
    	push esi
		mov esi,kb_analysis_buffer_qty
		cmp byte [esi],0x10
		jge .ommit_odd_entrance

    	push ebx
    	push edx
    	push ecx
    	xor eax,eax
    	mov al, [kb_analysis_buffer]

		mov edi, digit_table_index
		mov cx, [edi]
		mov edx, __DIGIT_TABLE_START
		add edx, ecx
		mov cl,0
		mov cl, [esi]
		shr cl,1
		add edx, ecx

    	mov [edx],al
    	pop ecx
    	pop edx
    	pop ebx
       	.ommit_odd_entrance:
    	pop esi
    	jmp .index_refresh

 ;   .border_situation:
 ;   	mov byte [edi], __KB_ANALYSIS_BUFF_LEN
 ;   	jmp .return_border_situation
	
	.kb_bf_index_overflow:
		push esi
		mov esi,kb_analysis_buffer_qty
		cmp byte [esi],0x10
		jge .ommit_dec
		dec ecx

		.ommit_dec:
		mov ebx, kb_analysis_buffer
		push eax
		xor eax,eax
		mov al, __KB_ANALYSIS_BUFF_LEN-1
		add ebx, eax
		pop eax
		pop esi
		jmp .return_kb_bf_index_overflow



is_empty:
	xor eax,eax
	mov ecx, __KB_ANALYSIS_BUFF_LEN
	mov esi, kb_analysis_buffer
	loop_is_empty:
		or al,[esi]
	loop loop_is_empty
	ret


GLOBAL	digit_table_index
GLOBAL 	keyboard_buffer
GLOBAL	keyboard_buffer_index
GLOBAL 	kb_analysis_buffer
GLOBAL 	kb_analysis_buffer_index
GLOBAL 	kb_analysis_buffer_qty
GLOBAL 	isr_kb_flag

section .bss
	isr_kb_flag					resb 	0x1 					;flag para saber si hubo interrupcion de teclado
	digit_table_index:			resw 	0x1						;contador de tabla de digitos
	keyboard_buffer:			resb 	__KEYBOARD_BUFFER_LEN	;buffer de teclado
	keyboard_buffer_index:		resb 	0x1 					;contador de buffer de teclado
	kb_analysis_buffer:			resb	__KB_ANALYSIS_BUFF_LEN	;buffer auxiliar
	kb_analysis_buffer_index:	resb 	0x1 					;indice del buffer auxiliar
	kb_analysis_buffer_qty 		resb 	0x1 					;cantidad de numeros ingresados al buffer
