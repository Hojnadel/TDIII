%define BREAKPOINT	xchg bx,bx


TASK2_TICKS	equ 20 		;20 tiks @ 10ms = 200msz

SCREEN_WIDTH	equ	160

MSG_ROW 		equ SCREEN_WIDTH*10
MSG_COL			equ 2*1			

NUMB_ROW		equ	SCREEN_WIDTH*10
NUMB_COL		equ	2*23

HEXA_PREFIX_ROW		equ	SCREEN_WIDTH*10
HEXA_PREFIX_COL		equ	2*20

SYSCALL_HALT 	EQU 	1
SYSCALL_READ 	EQU		2
SYSCALL_WRITE 	EQU 	3
SYSCALL_PRINT 	EQU 	4

GLOBAL	TASK2_TICKS
GLOBAL	task2
GLOBAL 	timer_counter_task2

EXTERN print_screen
EXTERN print_screen_T2

EXTERN	__DIGIT_TABLE_START
EXTERN 	digit_table_index

section .task2_TEXT

task2:
	;Muestro por pantalla la suma de dígitos por primera vez
	cmp byte [first_time_T2], 1
	jne	.not_first_time
	mov byte [first_time_T2], 0
	mov eax, SYSCALL_PRINT
	mov ebx, texto_T2
	mov ecx, text_hexa_prefix_T2
	mov edx, NUMB_COL
	mov edi, NUMB_ROW
	mov esi, acum_sum_T2
	int 0x80

	.not_first_time:
	mov eax, SYSCALL_READ 			;quiero leer
	mov esi, new_number_flag_T2 	;dónde quiero leer
	mov ecx, 1						;cuánto quiero leer
 	int 0x80

 	cmp al, 1 						;si AL está en 1, es que hubo un nuevo numero ingresado
 	jnz .continue
 	;Llamo a la syscall de escritura para apagar el flag
 	mov eax, SYSCALL_WRITE 			
 	mov edx, 0 						;apago el flag
 	mov ecx, 1 						;escribo 1 byte
 	mov edi, new_number_flag_T2 	;donde quiero escribir
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

	;Sumo y guardo
	add [acum_sum_T2], eax
	add [acum_sum_T2+4], ecx

	;LLamo a la syscall para imprimir en pantalla
	mov eax, SYSCALL_PRINT
	mov ebx, texto_T2
	mov ecx, text_hexa_prefix_T2
	mov edx, NUMB_COL
	mov edi, NUMB_ROW
	mov esi, acum_sum_T2
	int 0x80

	.continue:



	;Llamo la syscall para irme a halt
	mov eax, SYSCALL_HALT
	int 0x80

	jmp task2




GLOBAL	new_number_flag_T2
GLOBAL 	acum_sum_T2

section	.task2_BSS nobits
	acum_sum_T2 					resq	0x1						;acumumulador de suma
	

section .datos 		; No va en TASK2_DATOS porque NO es una variable EXCLUSIVA de la tarea. También acutúa sobre ella la ISR del timer
	timer_counter_task2:	dw 	TASK2_TICKS		;debe ejecutarse la task2 cada 200ms ==> Si interrumpe a 100Hz debe contar 20 ticks
	new_number_flag_T2		db 	0x0 					;flag de que hay un nuevo numero para sumar


section .task2_DATA
first_time_T2			db  0x1

texto_T2:
	dw MSG_ROW+MSG_COL
    db "Suma acumulada T2:",0

text_hexa_prefix_T2:
	dw HEXA_PREFIX_COL+HEXA_PREFIX_ROW
	db "0x ",0