EXTERN	__ROUTINES_LENGTH
EXTERN	__ROUTINES_START_ROM	;Origen
EXTERN 	__ROUTINES_START_RAM	;Destino

EXTERN cs_sel

section .copy
	USE32
	
	copy:
		mov ebp, esp		;cargo el puntero de pila en EBP
		mov ecx, [ebp+4]	;cargo cantidad, destino y origen direccionándome desde EBP
		mov edi, [ebp+8]
		mov esi, [ebp+12]
	ciclo_copy:
		mov	al, [esi]		;cargo en un registro el contenido de esi
		mov [edi], al		;cargo en edi el contenido de al
		inc esi				;incremento los punteros
		inc edi				;incremento los punteros
		dec ecx				;decremento el contador
		jne ciclo_copy		;si el flag NO está en 0, salto a ciclo
		ret 				;salgo


S_SCAN_CODE	equ	0x1F
Y_SCAN_CODE equ 0x15
U_SCAN_CODE equ 0x16
I_SCAN_CODE equ 0x17
O_SCAN_CODE equ 0x18
P_SCAN_CODE equ 0x19


section .rutinas
	polling_0x64:
		xor al, al
		in al, 0x64 			; consulto el puerto de estado del teclado
		bt eax,0x0 				; veo el bit 0 de al y lo pongo en el flag de carry 
		jc	.check_0x60			; si el carry está en '1', hubo actividad y consulto qué hay en data keyboard
		loop polling_0x64    	; si el carry es '0', vuelvo a consultar el puerto de estado

EXTERN	__DIGIT_TABLE_START
EXTERN 	__DIGIT_TABLE_SIZE

    .check_0x60:
    	xor al, al
		in al, 0x60 					;consulto el puerto de data de teclado
		cmp al, S_SCAN_CODE				;comparo el scan code leido con el de la 'S', si es 'S' me voy a halted
		jz .halted_state
		cmp al, Y_SCAN_CODE				;comparo el scan code leido con el de 'Y'
		jz .Y_pressed	
		cmp al, U_SCAN_CODE				;comparo el scan code leido con el de 'U'
		jz .U_pressed
		cmp al, I_SCAN_CODE				;comparo el scan code leido con el de 'I'
		jz .I_pressed
		cmp al, O_SCAN_CODE				;comparo el scan code leido con el de 'I'
		jz .O_pressed
		cmp al, P_SCAN_CODE
		jz .P_pressed

		bt eax, 0x7						;miro el bit 7 de al y lo pongo en el flag de carry
		jc polling_0x64 				;si el carry es '1', fue un release de una tecla y vuelvo a consultar por estado

		mov ebx, __DIGIT_TABLE_START	;si fue '0' (un press), cargo la dirección de la tabla
		add ebx, [digit_table_index]	;sumo la cantidad de valores guardados
		mov [ebx],al 					;guardo en la tabla la tecla presionada
		inc	word [digit_table_index] 	;incremento el contador de valores guardados
		mov ax, __DIGIT_TABLE_SIZE 		
		cmp ax,[digit_table_index] 		
		jz .reset_digit_table_index		;si el contador coincide con el tamaño de la tabla, salto a resetear el contador

    	jmp polling_0x64

    .reset_digit_table_index:
    	mov word [digit_table_index],0
    	jmp polling_0x64

    .halted_state:
    	hlt
    	jmp .halted_state

    .Y_pressed:				;genero un divide error
    	mov eax, 1			;cargo dividendo
    	mov ecx, 0			;cargo divisor
    	div	ecx
    	jmp polling_0x64

    .U_pressed:				;genero un opcode error
    	rsm
    	jmp polling_0x64

   	.I_pressed:				;genero una doble falta
   		xchg bx,bx			;genero un divide error
   		mov eax, 1			;cargo dividendo
    	mov ecx, 0			;cargo divisor
    	div	ecx
   		jmp polling_0x64

   	.O_pressed:				;genero una excepcion de proteccion general
   		mov ax,cs_sel	
   		mov ss,ax
   		jmp polling_0x64

   	.P_pressed:
   		mov eax,0x80000001			;genero una excepcion de overflow
   		add eax,0x80000001
   		into
   		jmp polling_0x64

GLOBAL polling_0x64

section .datos
	digit_table_index	resw 0x1		;contador de tabla de digitos

GLOBAL digit_table_index