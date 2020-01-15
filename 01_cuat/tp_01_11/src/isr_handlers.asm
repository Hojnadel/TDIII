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

section .isr
	
	EX0_DE_HANDLER:			; Division error
		mov dx,0
		hlt
		jmp EX0_DE_HANDLER

	EX1_DB_HANDLER:			; Debug Exception
		mov dx,1
		hlt
		jmp EX1_DB_HANDLER

	EX2_NMI_HANDLER:		; Nonmaskarable external interrupt
		mov dx,2
		hlt
		jmp EX2_NMI_HANDLER

	EX3_BP_HANDLER:			; Breakpoint
		mov dx,3
		hlt
		jmp EX3_BP_HANDLER

	EX4_OF_HANDLER:			; Overflow
		mov dx,4
		hlt
		jmp EX4_OF_HANDLER

	EX5_BR_HANDLER:			; Bound range exceed
		mov dx,5
		hlt
		jmp EX5_BR_HANDLER

	EX6_UD_HANDLER:			; Opcode error
		mov dx,6
		hlt
		jmp EX6_UD_HANDLER

	EX7_NM_HANDLER:  		; Dev not available
		mov dx,7
		hlt
		jmp EX7_NM_HANDLER

	EX8_DF_HANDLER:			; Double fault
		mov dx,8
		hlt
		jmp EX8_DF_HANDLER

	EX9_CSO_HANDLER:		; Coprocessor segment overrun
		mov dx,9
		hlt
		jmp EX9_CSO_HANDLER

	EX10_TS_HANDLER: 		; Invalid TSS
		mov dx,0XA
		hlt
		jmp EX10_TS_HANDLER

 	EX11_NP_HANDLER:		; Segment not present
		mov dx,0XB
		hlt
		jmp EX11_NP_HANDLER

	EX12_SS_HANDLER:		; Stack segment fault
		mov dx,0XC
		hlt
		jmp EX12_SS_HANDLER

	EX13_GP_HANDLER:		; General protection
		mov dx,0XD
		hlt
		jmp EX13_GP_HANDLER

	EX14_PF_HANDLER:		; Page fault
		mov dx,0XE
		mov ebx,CR2
		hlt
		jmp EX14_PF_HANDLER

	EX16_MF_HANDLER:		; Floating point error
		mov dx,16
		hlt
		jmp EX16_MF_HANDLER

	EX17_AC_HANDLER:		; Alignment check
		mov dx,17
		hlt
		jmp EX17_AC_HANDLER

	EX18_MC_HANDLER:		; Machine check
		mov dx,18
		hlt
		jmp EX18_MC_HANDLER

	EX19_XM_HANDLER:		; SIMD floating point exception
		mov dx,19
		hlt
		jmp EX19_XM_HANDLER

	EX20_VE_HANDLER:		; Virtualization exception
		mov dx,20
		hlt
		jmp EX20_VE_HANDLER

	;handler de timer0
	ISR0_0x20_HANDLER:			
		pushad
		mov dx,0x20
		dec dword [timer_counter_task1]
		;EOI
		mov al,0x20
		out 0x20,al

		popad
		iret


EXTERN 	isr_kb_flag
	;handler de teclado
	ISR1_0x21_HANDLER:				
		pushad
		mov byte [isr_kb_flag],1
		;EOI
		mov al,0x20
		out 0x20,al

		popad
		iret

	ISR2_0x22_HANDLER:
		mov dx,0x22
		hlt
		jmp ISR2_0x22_HANDLER

	ISR3_0x23_HANDLER:
		mov dx,0x23
		hlt
		jmp ISR3_0x23_HANDLER

	ISR4_0x24_HANDLER:
		mov dx,0x24
		hlt
		jmp ISR4_0x24_HANDLER

	ISR5_0x25_HANDLER:
		mov dx,0x25
		hlt
		jmp ISR5_0x25_HANDLER

	ISR6_0x26_HANDLER:
		mov dx,0x26
		hlt
		jmp ISR6_0x26_HANDLER

	ISR7_0x27_HANDLER:
		mov dx,0x27
		hlt
		jmp ISR7_0x27_HANDLER

	ISR8_0x28_HANDLER:
		mov dx,0x28
		hlt
		jmp ISR8_0x28_HANDLER

	ISR9_0x29_HANDLER:
		mov dx,0x29
		hlt
		jmp ISR9_0x29_HANDLER

	ISR10_0x2A_HANDLER:
		mov dx,0x2A
		hlt
		jmp ISR10_0x2A_HANDLER

	ISR11_0x2B_HANDLER:
		mov dx,0x2B
		hlt
		jmp ISR11_0x2B_HANDLER

	ISR12_0x2C_HANDLER:
		mov dx,0x2C
		hlt
		jmp ISR12_0x2C_HANDLER

	ISR13_0x2D_HANDLER:
		mov dx,0x2D
		hlt
		jmp ISR13_0x2D_HANDLER

	ISR14_0x2E_HANDLER:
		mov dx,0x2E
		hlt
		jmp ISR14_0x2E_HANDLER

	ISR15_0x2F_HANDLER:
		mov dx,0x2F
		hlt
		jmp ISR15_0x2F_HANDLER


