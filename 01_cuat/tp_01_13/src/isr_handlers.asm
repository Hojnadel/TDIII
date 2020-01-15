%define	BREAKPOINT 	xchg bx,bx

GLOBAL	EX0_DE_HANDLER
GLOBAL 	EX1_DB_HANDLER
GLOBAL	EX2_NMI_HANDLER
GLOBAL 	EX3_BP_HANDLER
GLOBAL 	EX4_OF_HANDLER
GLOBAL 	EX5_BR_HANDLER
GLOBAL  EX6_UD_HANDLER
GLOBAL	EX7_NM_HANDLER
GLOBAL 	EX8_DF_HANDLER
GLOBAL 	EX9_CSO_HANDLER
GLOBAL 	EX10_TS_HANDLER
GLOBAL 	EX11_NP_HANDLER
GLOBAL	EX12_SS_HANDLER
GLOBAL 	EX13_GP_HANDLER
GLOBAL 	EX14_PF_HANDLER
GLOBAL 	EX16_MF_HANDLER
GLOBAL 	EX17_AC_HANDLER
GLOBAL 	EX18_MC_HANDLER
GLOBAL 	EX19_XM_HANDLER
GLOBAL  EX20_VE_HANDLER

GLOBAL 	ISR0_0x20_HANDLER
GLOBAL 	ISR1_0x21_HANDLER
GLOBAL 	ISR2_0x22_HANDLER
GLOBAL 	ISR3_0x23_HANDLER
GLOBAL 	ISR4_0x24_HANDLER
GLOBAL 	ISR5_0x25_HANDLER
GLOBAL 	ISR6_0x26_HANDLER
GLOBAL 	ISR7_0x27_HANDLER
GLOBAL 	ISR8_0x28_HANDLER
GLOBAL 	ISR9_0x29_HANDLER
GLOBAL 	ISR10_0x2A_HANDLER
GLOBAL 	ISR11_0x2B_HANDLER
GLOBAL 	ISR12_0x2C_HANDLER
GLOBAL 	ISR13_0x2D_HANDLER
GLOBAL 	ISR14_0x2E_HANDLER
GLOBAL 	ISR15_0x2F_HANDLER

use32

EXTERN 	check_0x60
EXTERN 	timer_counter_task1
EXTERN 	timer_counter_task2
EXTERN 	TASK1_TICKS
EXTERN 	TASK2_TICKS
EXTERN	__print_pf_error
EXTERN 	__page_missing_page

section .isr
	
	EX0_DE_HANDLER:			; Division error
		mov edx,0
		hlt
		jmp EX0_DE_HANDLER

	EX1_DB_HANDLER:			; Debug Exception
		mov edx,1
		hlt
		jmp EX1_DB_HANDLER

	EX2_NMI_HANDLER:		; Nonmaskarable external interrupt
		mov edx,2
		hlt
		jmp EX2_NMI_HANDLER

	EX3_BP_HANDLER:			; Breakpoint
		mov edx,3
		hlt
		jmp EX3_BP_HANDLER

	EX4_OF_HANDLER:			; Overflow
		mov edx,4
		hlt
		jmp EX4_OF_HANDLER

	EX5_BR_HANDLER:			; Bound range exceed
		mov edx,5
		hlt
		jmp EX5_BR_HANDLER

	EX6_UD_HANDLER:			; Opcode error
		mov edx,6
		hlt
		jmp EX6_UD_HANDLER

	EX7_NM_HANDLER:  		; Dev not available
		mov edx,7
		hlt
		jmp EX7_NM_HANDLER

	EX8_DF_HANDLER:			; Double fault
		mov edx,8
		hlt
		jmp EX8_DF_HANDLER

	EX9_CSO_HANDLER:		; Coprocessor segment overrun
		mov edx,9
		hlt
		jmp EX9_CSO_HANDLER

	EX10_TS_HANDLER: 		; Invalid TSS
		mov edx,0XA
		hlt
		jmp EX10_TS_HANDLER

 	EX11_NP_HANDLER:		; Segment not present
		mov edx,0XB
		hlt
		jmp EX11_NP_HANDLER

	EX12_SS_HANDLER:		; Stack segment fault
		mov edx,0XC
		hlt
		jmp EX12_SS_HANDLER

	EX13_GP_HANDLER:		; General protection
		mov edx,0XD
		hlt
		jmp EX13_GP_HANDLER

	EX14_PF_HANDLER:		; Page fault
		pushad
		mov ebx,CR2
		;push ebx
		call __print_pf_error
		;mov edx,0XE
		;call __page_missing_page
		;pop ebx
		;invlpg [ebx] 	
		popad
		add esp,4 		; "Popeo" el código de error
		iret

	EX16_MF_HANDLER:		; Floating point error
		mov edx,16
		hlt
		jmp EX16_MF_HANDLER

	EX17_AC_HANDLER:		; Alignment check
		mov edx,17
		hlt
		jmp EX17_AC_HANDLER

	EX18_MC_HANDLER:		; Machine check
		mov edx,18
		hlt
		jmp EX18_MC_HANDLER

	EX19_XM_HANDLER:		; SIMD floating point exception
		mov edx,19
		hlt
		jmp EX19_XM_HANDLER

	EX20_VE_HANDLER:		; Virtualization exception
		mov edx,20
		hlt
		jmp EX20_VE_HANDLER


FLAG_TASK0	EQU		0
FLAG_TASK1	EQU		1
FLAG_TASK2	EQU		2

GLOBAL FLAG_TASK0

	;handler de timer0  - Scheduler
	ISR0_0x20_HANDLER:			
		pushad
		;EOI
		mov al,0x20
		out 0x20,al
		dec word [timer_counter_task1] 		;Decremento el contador de la tarea 1
		jz .refresh_task1_counter 			;Si llego a cero, vuelvo a cargar el contador y hago el cambio de tarea
		
		dec word [timer_counter_task2] 		;Decremento el contador de la tarea 2
		jz .refresh_task2_counter			;Si llego a cero, vuelvo a cargar el contador y hago el cambio de tarea
		
		;Si no expiró ningún contador, debo correr la TASK0 (idle)
		mov byte [next_task], FLAG_TASK0
		jmp .check_task_change

		.refresh_task1_counter:
			mov word [timer_counter_task1], TASK1_TICKS		;Vuelvo a cargar el contador de la tarea 1
			mov byte [next_task], FLAG_TASK1 				;Cargo la tarea1 como proxima tarea a correr
			jmp .check_task_change

		.refresh_task2_counter:
			mov word [timer_counter_task2], TASK2_TICKS 	;Vulevo a cargar el contador de la tarea 2
			mov byte [next_task], FLAG_TASK2				;Cargo la tarea2 como proxima tarea a correr
			jmp .check_task_change

		.check_task_change:					;Chequeo si debo hacer cambio de tarea
			mov al, [next_task]				;Cargo en el acumulador la proxima tarea a correr
			cmp al, [task_running] 			;Comparo con la tarea que estaba corriendo
			popad 							;Hago el pop de los registros de uso general para poder guardar el contexto (si hay cambio)
			je .exit 						;Si es la misma tarea, no hago nada

		;Guardo el contexto
		mov dword [TSS_T0_eax], eax
		mov dword [TSS_T0_ebx], ebx
		mov dword [TSS_T0_ecx], ecx
		mov dword [TSS_T0_edx], edx
		pop eax 							;Popeo EIP
		mov dword [TSS_T0_eip], eax
		pop eax 							;Popeo CS
		mov word [TSS_T0_cs],	ax
		mov ax, ds
		mov word [TSS_T0_ds], ax
		mov ax, es
		mov word [TSS_T0_es], ax
		mov ax, ss
		mov word [TSS_T0_ss], ax
		mov eax, cr3
		mov dword [TSS_T0_cr3], eax
		pop eax 							;Popeo los EFLGAS
		mov dword [TSS_T0_eflags], eax
		mov dword [TSS_T0_ebp], ebp
		mov dword [TSS_T0_esp], esp

		;Me fijo a qué tarea tengo que saltar y cargo la dirección del directorio de páginas de dicha tarea
		cmp byte [next_task], FLAG_TASK0
		jne .check_t1
		mov eax, __PAGE_DIRECTORY_ADDR_TASK0
		jmp .load_context

		.check_t1:
		cmp byte [next_task], FLAG_TASK1
		jne .check_t2
		mov eax, __PAGE_DIRECTORY_ADDR_TASK1
		jmp .load_context

		.check_t2:
		mov eax, __PAGE_DIRECTORY_ADDR_TASK2
		
		.load_context:
		mov cr3, eax 			;Cargo el directorio de paginación que corresponda
		mov al, [next_task]		;Actualizo la tarea actual
		mov [task_running], al

		;Cargo el contexto
		mov dword esp, [TSS_T0_esp]
		mov dword ebp, [TSS_T0_ebp]
		mov dword eax, [TSS_T0_eflags]
		push eax
		mov dword eax, [TSS_T0_cr3]
		mov cr3, eax
		mov word ax, [TSS_T0_ss]
		mov ss,ax
		mov word ax, [TSS_T0_es]
		mov es, ax
		mov word ax, [TSS_T0_ds]
		mov ds, ax
		mov word ax, [TSS_T0_cs]
		push eax
		mov dword eax, [TSS_T0_eip]
		push eax
		mov dword edx, [TSS_T0_edx]
		mov	dword ecx, [TSS_T0_ecx]
		mov dword ebx, [TSS_T0_ebx]
		mov	dword eax, [TSS_T0_eax]

		.exit:
		iret


EXTERN check_0x60_kb

	;handler de teclado
	ISR1_0x21_HANDLER:				
		pushad
		;mov byte [isr_kb_flag],
		call check_0x60_kb
		;EOI
		mov al,0x20
		out 0x20,al

		popad
		iret

	ISR2_0x22_HANDLER:
		mov edx,0x22
		hlt
		jmp ISR2_0x22_HANDLER

	ISR3_0x23_HANDLER:
		mov edx,0x23
		hlt
		jmp ISR3_0x23_HANDLER

	ISR4_0x24_HANDLER:
		mov edx,0x24
		hlt
		jmp ISR4_0x24_HANDLER

	ISR5_0x25_HANDLER:
		mov edx,0x25
		hlt
		jmp ISR5_0x25_HANDLER

	ISR6_0x26_HANDLER:
		mov edx,0x26
		hlt
		jmp ISR6_0x26_HANDLER

	ISR7_0x27_HANDLER:
		mov edx,0x27
		hlt
		jmp ISR7_0x27_HANDLER

	ISR8_0x28_HANDLER:
		mov edx,0x28
		hlt
		jmp ISR8_0x28_HANDLER

	ISR9_0x29_HANDLER:
		mov edx,0x29
		hlt
		jmp ISR9_0x29_HANDLER

	ISR10_0x2A_HANDLER:
		mov edx,0x2A
		hlt
		jmp ISR10_0x2A_HANDLER

	ISR11_0x2B_HANDLER:
		mov edx,0x2B
		hlt
		jmp ISR11_0x2B_HANDLER

	ISR12_0x2C_HANDLER:
		mov edx,0x2C
		hlt
		jmp ISR12_0x2C_HANDLER

	ISR13_0x2D_HANDLER:
		mov edx,0x2D
		hlt
		jmp ISR13_0x2D_HANDLER

	ISR14_0x2E_HANDLER:
		mov edx,0x2E
		hlt
		jmp ISR14_0x2E_HANDLER

	ISR15_0x2F_HANDLER:
		mov edx,0x2F
		hlt
		jmp ISR15_0x2F_HANDLER



GLOBAL task_running

section	.bss	nobits
	next_task 		resb 	0x1
	task_running	resb  	0x1



EXTERN __TASK0_TEXT_LINEAR_ADDR
EXTERN __TASK1_TEXT_LINEAR_ADDR
EXTERN __TASK2_TEXT_LINEAR_ADDR
EXTERN __PAGE_DIRECTORY_ADDR_TASK0
EXTERN __PAGE_DIRECTORY_ADDR_TASK1
EXTERN __PAGE_DIRECTORY_ADDR_TASK2
EXTERN __TASK0_STACK_END
EXTERN __TASK1_STACK_END
EXTERN __TASK2_STACK_END
EXTERN ds_sel_ram
EXTERN cs_sel_ram

section .tss_TASK0
	TSS_T0_eax 		dd 	0
	TSS_T0_ebx 		dd  0
	TSS_T0_ecx 		dd 	0
	TSS_T0_edx 		dd 	0
	TSS_T0_edi 		dd 	0
	TSS_T0_esi 		dd 	0
	TSS_T0_eip		dd 	__TASK0_TEXT_LINEAR_ADDR
	TSS_T0_ebp 		dd 	0
	TSS_T0_esp 		dd 	__TASK0_STACK_END
	TSS_T0_eflags 	dd 	0x202
	TSS_T0_cs 		dw 	cs_sel_ram
	TSS_T0_ds 		dw 	ds_sel_ram
	TSS_T0_es 		dw  ds_sel_ram
	TSS_T0_ss 		dw 	ds_sel_ram
	TSS_T0_cr3 		dd 	__PAGE_DIRECTORY_ADDR_TASK0


section .tss_TASK1
	TSS_T1_eax 		dd 	0
	TSS_T1_ebx 		dd  0
	TSS_T1_ecx 		dd 	0
	TSS_T1_edx 		dd 	0
	TSS_T1_edi 		dd 	0
	TSS_T1_esi 		dd 	0
	TSS_T1_eip		dd 	__TASK1_TEXT_LINEAR_ADDR
	TSS_T1_ebp 		dd 	0
	TSS_T1_esp 		dd 	__TASK1_STACK_END
	TSS_T1_eflags 	dd 	0x202
	TSS_T1_cs 		dw 	cs_sel_ram
	TSS_T1_ds 		dw 	ds_sel_ram
	TSS_T1_es 		dw  ds_sel_ram
	TSS_T1_ss 		dw 	ds_sel_ram
	TSS_T1_cr3 		dd 	__PAGE_DIRECTORY_ADDR_TASK1


section .tss_TASK2
	TSS_T2_eax 		dd 	0
	TSS_T2_ebx 		dd  0
	TSS_T2_ecx 		dd 	0
	TSS_T2_edx 		dd 	0
	TSS_T2_edi 		dd 	0
	TSS_T2_esi 		dd 	0
	TSS_T2_eip		dd 	__TASK2_TEXT_LINEAR_ADDR
	TSS_T2_ebp 		dd 	0
	TSS_T2_esp 		dd 	__TASK2_STACK_END
	TSS_T2_eflags 	dd 	0x202
	TSS_T2_cs 		dw 	cs_sel_ram
	TSS_T2_ds 		dw 	ds_sel_ram
	TSS_T2_es 		dw  ds_sel_ram
	TSS_T2_ss 		dw 	ds_sel_ram
	TSS_T2_cr3 		dd 	__PAGE_DIRECTORY_ADDR_TASK2