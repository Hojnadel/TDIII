%define BREAKPOINT	xchg bx,bx


TASK1_TICKS	equ 10 		;10 tiks @ 10ms = 100ms

SCREEN_WIDTH	equ	160

MSG_ROW 		equ SCREEN_WIDTH*5
MSG_COL			equ 2*1			

NUMB_ROW		equ	SCREEN_WIDTH*5
NUMB_COL		equ	2*23

HEXA_PREFIX_ROW		equ	SCREEN_WIDTH*5
HEXA_PREFIX_COL		equ	2*20

SYSCALL_HALT 	EQU 	1
SYSCALL_READ 	EQU		2
SYSCALL_WRITE 	EQU 	3
SYSCALL_PRINT 	EQU 	4

GLOBAL	TASK1_TICKS
GLOBAL	task1
GLOBAL 	timer_counter_task1

EXTERN print_screen

EXTERN	__DIGIT_TABLE_START
EXTERN 	digit_table_index

section .task1_TEXT



task1:
	cmp byte [first_time_T1], 1
	jne	.not_first_time
	mov byte [first_time_T1], 0
	mov eax, SYSCALL_PRINT
	mov ebx, texto_T1
	mov ecx, text_hexa_prefix_T1
	mov edx, NUMB_COL
	mov edi, NUMB_ROW
	mov esi, acum_sum_T1
	int 0x80

	.not_first_time:
	;Veo si hubo un nuevo número ingresado
	mov eax, SYSCALL_READ 			;quiero leer
	mov esi, new_number_flag_T1 	;dónde quiero leer
	mov ecx, 1						;cuánto quiero leer
 	int 0x80

 	cmp al, 1 						;si AL está en 1, es que hubo un nuevo numero ingresado
 	jnz .continue
 	;Llamo a la syscall de escritura para apagar el flag
 	mov eax, SYSCALL_WRITE 			
 	mov edx, 0 						;apago el flag
 	mov ecx, 1 						;escribo 1 byte
 	mov edi, new_number_flag_T1 	;donde quiero escribir
 	int 0x80

	;Llamo a la syscall para obtener la direccion de memoria del último numero ingresado
	mov eax, SYSCALL_READ
	mov ecx, 4
	mov esi, digit_table_index 		;leo el indice del proximo nuemor a ingresar, se guarda en EAX
	int 0x80
	sub eax, 0x8 					;le resto 8 para tener el índice del último número ingresado

	mov esi, __DIGIT_TABLE_START 	;posición inicial de la tabla de dígitos
	add esi, eax 					;tengo en ESI la posición de memoria del último número ingresado

	;LLamo a la syscall para obtener el último número ingresado, devuelve parte baja por EAX, y parte alta por ECX
	mov eax, SYSCALL_READ
	mov ecx, 8
	int 0x80

	;Realizo la suma con SIMD
	mov dword [simd_aux0], eax 		;guardo la parte baja en un buffer local
	mov dword [simd_aux1], ecx 		;guardo la parte alta en un buffer local
	movdqu XMM0, [simd_aux0] 		;cargo el registro con parte alta y baja
	movdqu XMM1,[acum_sum_T1]
	paddq XMM0, XMM1
	movdqu [acum_sum_T1], XMM0

	;LLamo a la syscall para imprimir en pantalla
	mov eax, SYSCALL_PRINT
	mov ebx, texto_T1
	mov ecx, text_hexa_prefix_T1
	mov edx, NUMB_COL
	mov edi, NUMB_ROW
	mov esi, acum_sum_T1
	int 0x80

	.continue:
	;Llamo la syscall para irme a halt
	mov eax, SYSCALL_HALT
	int 0x80

	jmp task1




GLOBAL	new_number_flag_T1
GLOBAL 	acum_sum_T1
GLOBAL 	SIMD_CONTEXT_T1

section	.task1_BSS nobits
	simd_aux0 						resd 	0x1
	simd_aux1 						resd 	0x1
	acum_sum_T1 					resq	0x1						;acumumulador de suma


section .datos 		; No va en TASK1_DATOS porque NO es una variable EXCLUSIVA de la tarea. También acutúa sobre ella la ISR del timer
	timer_counter_task1:	dw 	TASK1_TICKS		;debe ejecutarse la task1 cada 1seg ==> Si interrumpe a 10Hz debe contar 100 ticks
	new_number_flag_T1		db 	0x0 					;flag de que hay un nuevo numero para sumar



section .task1_DATA
align 16
SIMD_CONTEXT_T1		times 512 db 0x0
first_time_T1			db  0x1

texto_T1:
	dw MSG_ROW+MSG_COL
    db "Suma acumulada T1:",0

text_hexa_prefix_T1:
	dw HEXA_PREFIX_COL+HEXA_PREFIX_ROW
	db "0x ",0