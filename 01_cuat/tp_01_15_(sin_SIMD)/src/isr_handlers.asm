%define	BREAKPOINT 	xchg bx,bx

;TSS Offsets
OFFSET_BACKLINK   EQU 0
OFFSET_ESP0       EQU 4
OFFSET_SS0        EQU 8
OFFSET_ESP1       EQU 12
OFFSET_SS1        EQU 16
OFFSET_ESP2       EQU 20
OFFSET_SS2        EQU 24
OFFSET_CR3        EQU 28
OFFSET_EIP        EQU 32
OFFSET_EFLAGS     EQU 36
OFFSET_EAX        EQU 40
OFFSET_ECX        EQU 44
OFFSET_EDX        EQU 48
OFFSET_EBX        EQU 52
OFFSET_ESP        EQU 56
OFFSET_EBP        EQU 60
OFFSET_ESI        EQU 64
OFFSET_EDI        EQU 68
OFFSET_ES         EQU 72
OFFSET_CS         EQU 76
OFFSET_SS         EQU 80
OFFSET_DS         EQU 84
OFFSET_FS         EQU 88
OFFSET_GS         EQU 92
OFFSET_LDT        EQU 96
OFFSET_T          EQU 100
OFFSET_BITMAP     EQU 102

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
GLOBAL 	ISR128_0x80_HANDLER

use32

EXTERN 	check_0x60
EXTERN 	timer_counter_task1
EXTERN 	timer_counter_task2
EXTERN 	TASK1_TICKS
EXTERN 	TASK2_TICKS
EXTERN	__print_pf_error
EXTERN 	__page_missing_page

EXTERN 	cs_sel_ram_pl3

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
		BREAKPOINT
		mov ebx,CR2
		push ebx
		call __print_pf_error
		;mov edx,0XE
		;call __page_missing_page
		pop ebx
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
		mov dword [tss_T0+OFFSET_EAX], eax
		mov dword [tss_T0+OFFSET_EBX], ebx
		mov dword [tss_T0+OFFSET_ECX], ecx
		mov dword [tss_T0+OFFSET_EDX], edx
		mov dword [tss_T0+OFFSET_EDI], edi
		mov dword [tss_T0+OFFSET_ESI], esi
		pop eax 							
		mov dword [tss_T0+OFFSET_EIP], eax 		
		pop eax 							
		mov word [tss_T0+OFFSET_CS],	ax 
		mov ax, ds
		mov word [tss_T0+OFFSET_DS], ax
		mov ax, es
		mov word [tss_T0+OFFSET_ES], ax
		;mov ax, ss
		;mov word [TSS_T0_ss], ax
		mov eax, cr3
		mov dword [tss_T0+OFFSET_CR3], eax
		pop eax 							;Popeo los EFLGAS
		mov dword [tss_T0+OFFSET_EFLAGS], eax
		mov dword [tss_T0+OFFSET_EBP], ebp
		;mov dword [TSS_T0_esp], esp

		;Si vengo de PL3 debo guardar el SS
		cmp byte [tss_T0+OFFSET_CS], cs_sel_ram_pl3
		je .save_ss

		;Si no venía de PL3, lo guardo de la pila
		mov dword [tss_T0+OFFSET_ESP], esp
		jmp .task_change

		.save_ss:
		pop eax
		mov dword [tss_T0+OFFSET_ESP], eax  
        pop eax
        mov word [tss_T0+OFFSET_SS], ax   


		;Me fijo a qué tarea tengo que saltar y cargo la dirección del directorio de páginas de dicha tarea
		.task_change:
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


		;Me fijo si voy al mismo o distinto PL 
		mov ax, [tss_T0+OFFSET_CS]
        mov bx, cs
        cmp ax, bx
        jne .different_PL

        ;Como tienen el mismo PL
        mov dword esp, [tss_T0+OFFSET_ESP]  
        jmp .continue

        .different_PL:
        mov word ax,   [tss_T0+OFFSET_SS] 
        ;and dword eax, 0x0000FFFF
        push eax
        mov dword eax, [tss_T0+OFFSET_ESP]   
        push eax

		;Cargo el resto del contexto
		.continue
		mov word ax, [tss_T0+OFFSET_ES]
		mov es, ax
		mov word ax, [tss_T0+OFFSET_DS]
		mov ds, ax

		mov dword ebp, [tss_T0+OFFSET_EBP]
		mov dword eax, [tss_T0+OFFSET_EFLAGS]
		push eax
		mov word ax, [tss_T0+OFFSET_CS]
		push eax
		mov dword eax, [tss_T0+OFFSET_EIP]
		push eax
		mov dword esi, [tss_T0+OFFSET_ESI]
		mov dword esi, [tss_T0+OFFSET_EDI]
		mov dword edx, [tss_T0+OFFSET_EDX]
		mov	dword ecx, [tss_T0+OFFSET_ECX]
		mov dword ebx, [tss_T0+OFFSET_EBX]
		mov	dword eax, [tss_T0+OFFSET_EAX]

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


SYSCALL_HALT 	EQU 	1
SYSCALL_READ 	EQU		2
SYSCALL_WRITE 	EQU 	3
SYSCALL_PRINT 	EQU 	4


	ISR128_0x80_HANDLER:
		;Handler de la system call
		cmp eax, SYSCALL_HALT
		je .halt_mode
		cmp eax, SYSCALL_READ
		je .read_mode
		cmp eax, SYSCALL_WRITE
		je .write_mode
		cmp eax, SYSCALL_PRINT
		je .print_mode
		
		.halt_mode:
			hlt
			jmp .exit

		.read_mode:
			cmp ecx, 1
			jne .isnt_byte_r
			mov al, [esi]
			jmp .exit
			
			.isnt_byte_r:
			cmp ecx, 4
			jne .isnt_dw_r
			mov eax, [esi]
			jmp .exit

			.isnt_dw_r:
			cmp ecx, 8
			jne .isnt_qw_r
			mov eax, [esi]
			mov ecx, [esi+4]
			jmp .exit

			.isnt_qw_r:
			jmp .exit

		.write_mode:
			cmp ecx, 1 		;si escribo solo 1 byte
			jne .isnt_byte_w
			mov [edi], dl 
			jmp .exit

			.isnt_byte_w
			jmp .exit

		.print_mode:
			push esi
			push edi
			push edx
			push ecx
			push ebx
			call print_screen
			add esp,5*4
			jmp .exit

		.exit:
		iret



GLOBAL task_running
EXTERN 	print_screen_T1
EXTERN 	print_screen_T2
EXTERN 	print_screen

section	.bss	nobits
	next_task 		resb 	0x1
	task_running	resb  	0x1



EXTERN __TASK0_TEXT_LINEAR_ADDR
EXTERN __TASK1_TEXT_LINEAR_ADDR
EXTERN __TASK2_TEXT_LINEAR_ADDR
EXTERN __PAGE_DIRECTORY_ADDR_TASK0
EXTERN __PAGE_DIRECTORY_ADDR_TASK1
EXTERN __PAGE_DIRECTORY_ADDR_TASK2
EXTERN __TASK0_KERNEL_STACK_END
EXTERN __TASK1_KERNEL_STACK_END
EXTERN __TASK2_KERNEL_STACK_END
EXTERN __TASK0_USER_STACK_END
EXTERN __TASK1_USER_STACK_END
EXTERN __TASK2_USER_STACK_END
EXTERN ds_sel_ram
EXTERN cs_sel_ram
EXTERN ds_sel_ram_pl3
EXTERN cs_sel_ram_pl3

GLOBAL 	tss_T0
GLOBAL 	tss_T1
GLOBAL 	tss_T2


section .tss_TASK0
	tss_T0 	times 104 db 0



section .tss_TASK1
	tss_T1 	times 104 db 0


section .tss_TASK2
	tss_T2 	times 104 db 0

