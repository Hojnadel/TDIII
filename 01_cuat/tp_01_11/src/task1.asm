%define BREAKPOINT	xchg bx,bx


TASK1_TICKS	equ 100 		;100 tiks @ 10ms = 1seg

GLOBAL	TASK1_TICKS
GLOBAL	task1
GLOBAL 	timer_counter_task1

EXTERN	__DIGIT_TABLE_START
EXTERN 	digit_table_index

section .task1_TEXT

task1:
	;Veo si hubo un nuevo nunero ingresado
	cmp byte [new_number_flag],1
	jnz .continue
	
	mov byte [new_number_flag],0
	mov eax, [acum_sum]			;parte baja
	mov ebx, [acum_sum+4]		;parte alta

	mov edx, __DIGIT_TABLE_START		;posición inicial de la tabla de dígitoss
	mov esi, [digit_table_index]		;posición en la tabla donde estará el próximo número a ingresar
	sub	esi, 0x8 						;posición en la tabla del número anterior
	add edx, esi 						;posicion en memoria del número anterior

	add eax, [edx]						;sumo la parte baja
	adc ebx, [edx+4] 					;sumo la parte alta y el carry

	mov [acum_sum], eax 				;guardo la parte baja en el acumumulador
	mov	[acum_sum+4], ebx				;guardo la parte alta en el acumumulador

	.continue:
	ret


GLOBAL	new_number_flag
GLOBAL 	timer_counter_task1
GLOBAL 	acum_sum


section	.task1_BSS nobits
	acum_sum 					resq	0x1						;acumumulador de suma
	new_number_flag				resb 	0x1 					;flag de que hay un nuevo numero para sumar




section .datos 		; No va en TASK1_DATOS porque NO es una variable EXCLUSIVA de la tarea. También acutúa sobre ella la ISR del timer
	timer_counter_task1:	dw 	TASK1_TICKS		;debe ejecutarse la task1 cada 1seg ==> Si interrumpe a 10Hz debe contar 100 ticks