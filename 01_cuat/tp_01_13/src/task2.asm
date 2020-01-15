%define BREAKPOINT	xchg bx,bx


TASK2_TICKS	equ 20 		;20 tiks @ 10ms = 200ms

GLOBAL	TASK2_TICKS
GLOBAL	task2
GLOBAL 	timer_counter_task2

EXTERN print_screen_T2

EXTERN	__DIGIT_TABLE_START
EXTERN 	digit_table_index

section .task2_TEXT

task2:
	;Veo si hubo un nuevo número ingresado
	cmp byte [new_number_flag_T2],1
	jnz .continue
	
	mov byte [new_number_flag_T2],0
	mov eax, [acum_sum_T2]			;parte baja
	mov ebx, [acum_sum_T2+4]		;parte alta

	mov edx, __DIGIT_TABLE_START		;posición inicial de la tabla de dígitos
	mov esi, [digit_table_index]		;posición en la tabla donde estará el próximo número a ingresar
	sub	esi, 0x8 						;posición en la tabla del número anterior
	add edx, esi 						;posicion en memoria del número anterior

	add eax, [edx]						;sumo la parte baja
	adc ebx, [edx+4] 					;sumo la parte alta y el carry

	mov [acum_sum_T2], eax 				;guardo la parte baja en el acumumulador
	mov	[acum_sum_T2+4], ebx				;guardo la parte alta en el acumumulador

	mov dword edi, [acum_sum_T2] 			;guardo la parte baja de la suma acumulada
	;cmp edi, RAM_LIMINT 				;comparo con el límite de la RAM, si es mayor, no hago nada
	;ja	.continue
	;	mov dword edi, [edi] 			;si es menor que la RAM, intento acceder a esa posición de memoria
	.continue:

	
	call print_screen_T2

	hlt
	jmp task2


GLOBAL	new_number_flag_T2
GLOBAL 	acum_sum_T2

section	.task2_BSS nobits
	acum_sum_T2 					resq	0x1						;acumumulador de suma
	




section .datos 		; No va en TASK2_DATOS porque NO es una variable EXCLUSIVA de la tarea. También acutúa sobre ella la ISR del timer
	timer_counter_task2:	dw 	TASK2_TICKS		;debe ejecutarse la task2 cada 200ms ==> Si interrumpe a 100Hz debe contar 20 ticks
	new_number_flag_T2		db 	0x0 					;flag de que hay un nuevo numero para sumar