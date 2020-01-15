EXTERN	__ROUTINES_LENGTH
EXTERN	__ROUTINES_START_ROM	;Origen
EXTERN 	__ROUTINES_START_RAM	;Destino


section .copy
	USE32

	;rutina copy: popea fuente, destino, tamaño
	copy:
		;mov esi, __ROUTINES_START_ROM
		;mov edi, __ROUTINES_START_RAM
		;mov ecx, __ROUTINES_LENGTH
		mov ebp, esp
		mov ecx, [ebp+4]
		mov edi, [ebp+8]
		mov esi, [ebp+12]
	ciclo_copy:
		mov	al, [esi]		;cargo en un registro el contenido de esi
		mov [edi], al		;cargo en edi el contenido de al
		inc esi				;incremento los punteros
		inc edi				;incremento los punteros
		dec ecx				;decremento el contador
		jne ciclo_copy			;si el flag NO está en 0, salto a ciclo
		ret 				;salgo






