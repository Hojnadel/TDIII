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


section .isr
	
	EX0_DE_HANDLER:			; Division error
		mov dx,0
		hlt

	EX1_DB_HANDLER:			; Debug Exception
		mov dx,1
		hlt

	EX2_NMI_HANDLER:		; Nonmaskarable external interrupt
		mov dx,2
		hlt

	EX3_BP_HANDLER:			; Breakpoint
		mov dx,3
		hlt

	EX4_OF_HANDLER:			; Overflow
		mov dx,4
		hlt

	EX5_BR_HANDLER:			; Bound range exceed
		mov dx,5
		hlt

	EX6_UD_HANDLER:			; Opcode error
		mov dx,6
		hlt

	EX7_NM_HANDLER:  		; Dev not available
		mov dx,7
		hlt

	EX8_DF_HANDLER:			; Double fault
		mov dx,8
		hlt

	EX9_CSO_HANDLER:		; Coprocessor segment overrun
		mov dx,9
		hlt

	EX10_TS_HANDLER: 		; Invalid TSS
		mov dx,0XA
		hlt

 	EX11_NP_HANDLER:		; Segment not present
		mov dx,0XB
		hlt

	EX12_SS_HANDLER:		; Stack segment fault
		mov dx,0XC
		hlt

	EX13_GP_HANDLER:		; General protection
		mov dx,0XD
		hlt

	EX14_PF_HANDLER:		; Page fault
		mov dx,0XE
		hlt

	EX16_MF_HANDLER:		; Floating point error
		mov dx,16
		hlt

	EX17_AC_HANDLER:		; Alignment check
		mov dx,17
		hlt

	EX18_MC_HANDLER:		; Machine check
		mov dx,18
		hlt

	EX19_XM_HANDLER:		; SIMD floating point exception
		mov dx,19
		hlt

	EX20_VE_HANDLER:		; Virtualization exception
		mov dx,20
		hlt

	ISR0_0x20_HANDLER:
		mov dx,0x20
		hlt

	ISR1_0x21_HANDLER:
		mov dx,0x21
		hlt

	ISR2_0x22_HANDLER:
		mov dx,0x22
		hlt

	ISR3_0x23_HANDLER:
		mov dx,0x23
		hlt

	ISR4_0x24_HANDLER:
		mov dx,0x24
		hlt

	ISR5_0x25_HANDLER:
		mov dx,0x25
		hlt

	ISR6_0x26_HANDLER:
		mov dx,0x26
		hlt

	ISR7_0x27_HANDLER:
		mov dx,0x27
		hlt

	ISR8_0x28_HANDLER:
		mov dx,0x28
		hlt

	ISR9_0x29_HANDLER:
		mov dx,0x29
		hlt

	ISR10_0x2A_HANDLER:
		mov dx,0x2A
		hlt

	ISR11_0x2B_HANDLER:
		mov dx,0x2B
		hlt

	ISR12_0x2C_HANDLER:
		mov dx,0x2C
		hlt

	ISR13_0x2D_HANDLER:
		mov dx,0x2D
		hlt

	ISR14_0x2E_HANDLER:
		mov dx,0x2E
		hlt

	ISR15_0x2F_HANDLER:
		mov dx,0x2F
		hlt
