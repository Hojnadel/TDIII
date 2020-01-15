%define BREAKPOINT	xchg bx,bx


TASK1_TICKS	equ 10 		;10 tiks @ 10ms = 100ms

GLOBAL	TASK1_TICKS
GLOBAL	task1
GLOBAL 	timer_counter_task1

EXTERN print_screen_T1

EXTERN	__DIGIT_TABLE_START
EXTERN 	digit_table_index

section .task1_TEXT



task1:
	;Veo si hubo un nuevo número ingresado
	cmp byte [new_number_flag_T1],1
	jnz .continue
	
	mov byte [new_number_flag_T1],0
	mov eax, [acum_sum_T1]			;parte baja
	mov ebx, [acum_sum_T1+4]		;parte alta

	mov edx, __DIGIT_TABLE_START		;posición inicial de la tabla de dígitos
	mov esi, [digit_table_index]		;posición en la tabla donde estará el próximo número a ingresar
	sub	esi, 0x8 						;posición en la tabla del número anterior
	add edx, esi 						;posicion en memoria del número anterior

	add eax, [edx]						;sumo la parte baja
	adc ebx, [edx+4] 					;sumo la parte alta y el carry

	mov [acum_sum_T1], eax 				;guardo la parte baja en el acumumulador
	mov	[acum_sum_T1+4], ebx				;guardo la parte alta en el acumumulador

	;mov dword edi, [acum_sum_T1] 			;guardo la parte baja de la suma acumulada
	;cmp edi, RAM_LIMINT 				;comparo con el límite de la RAM, si es mayor, no hago nada
	;ja	.continue
	;	mov dword edi, [edi] 			;si es menor que la RAM, intento acceder a esa posición de memoria
	.continue:


	call print_screen_T1

	hlt
	jmp task1


GLOBAL	new_number_flag_T1
GLOBAL 	acum_sum_T1

section	.task1_BSS nobits
	acum_sum_T1 					resq	0x1						;acumumulador de suma

section .datos 		; No va en TASK1_DATOS porque NO es una variable EXCLUSIVA de la tarea. También acutúa sobre ella la ISR del timer
	timer_counter_task1:	dw 	TASK1_TICKS		;debe ejecutarse la task1 cada 1seg ==> Si interrumpe a 10Hz debe contar 100 ticks
	new_number_flag_T1		db 	0x0 					;flag de que hay un nuevo numero para sumar
