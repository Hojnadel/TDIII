%define BREAKPOINT	xchg bx,bx

use32

GLOBAL	infinit_loop

section .kernel

;	Task1 EXTERNS
EXTERN  task1
EXTERN 	timer_counter_task1
EXTERN	TASK1_TICKS

;	Rutina de teclado EXTERNS
EXTERN 	check_0x60_kb
EXTERN 	isr_kb_flag
EXTERN	new_number_flag
	
infinit_loop:
	
	hlt

	;checkeo si el contador de task1 llego a 0
	;cmp word [timer_counter_task1],0
	;jnz	return_task1								;si la cuenta no es cero, sigo de largo
	;mov word [timer_counter_task1], TASK1_TICKS		;reinicio la cuenta
	;call task1 										;llamo a la tarea 1
	;call print_screen

	return_task1:
	;checkeo si hubo interrupcion de teclado, isr_kb_flag activo en alto
	;cmp byte [isr_kb_flag],1 			
	;jnz	return_check_0x60_kb						;si el flag es 1, sigo con la llamada a la función
	;mov byte [isr_kb_flag],0						;apago el flag de que hubo actividad de teclado
	;call check_0x60_kb 								;llamo a la función de teclado
	
	;return_check_0x60_kb:
	jmp infinit_loop
