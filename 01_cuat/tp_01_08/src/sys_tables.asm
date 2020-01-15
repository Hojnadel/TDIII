  ; Descriptores de la GDT

EXTERN  EX0_DE_HANDLER
EXTERN  EX1_DB_HANDLER
EXTERN  EX2_NMI_HANDLER
EXTERN  EX3_BP_HANDLER
EXTERN  EX4_OF_HANDLER
EXTERN  EX5_BR_HANDLER
EXTERN  EX6_UD_HANDLER
EXTERN  EX7_NM_HANDLER
EXTERN  EX8_DF_HANDLER
EXTERN  EX9_CSO_HANDLER
EXTERN  EX10_TS_HANDLER
EXTERN  EX11_NP_HANDLER
EXTERN  EX12_SS_HANDLER
EXTERN  EX13_GP_HANDLER
EXTERN  EX14_PF_HANDLER
EXTERN  EX16_MF_HANDLER
EXTERN  EX17_AC_HANDLER
EXTERN  EX18_MC_HANDLER
EXTERN  EX19_XM_HANDLER
EXTERN  EX20_VE_HANDLER

EXTERN 	ISR0_0x20_HANDLER
EXTERN 	ISR1_0x21_HANDLER
EXTERN 	ISR2_0x22_HANDLER
EXTERN 	ISR3_0x23_HANDLER
EXTERN 	ISR4_0x24_HANDLER
EXTERN 	ISR5_0x25_HANDLER
EXTERN 	ISR6_0x26_HANDLER
EXTERN 	ISR7_0x27_HANDLER
EXTERN 	ISR8_0x28_HANDLER
EXTERN 	ISR9_0x29_HANDLER
EXTERN 	ISR10_0x2A_HANDLER
EXTERN 	ISR11_0x2B_HANDLER
EXTERN 	ISR12_0x2C_HANDLER
EXTERN 	ISR13_0x2D_HANDLER
EXTERN 	ISR14_0x2E_HANDLER
EXTERN 	ISR15_0x2F_HANDLER

use32

GLOBAL 	cs_sel_ram
GLOBAL 	ds_sel_ram
GLOBAL 	gdt_ram
GLOBAL	img_gdtr_ram

GLOBAL  img_idtr


section .sys_tables

  gdt_ram:
            db 0,0,0,0,0,0,0,0  ;Descriptor nulo
  ds_sel_ram    equ $-gdt_ram
            db 0xFF, 0xFF, 0, 0, 0, 0x92, 0xCF, 0
  cs_sel_ram    equ $-gdt_ram
            db 0xFF, 0xFF, 0, 0, 0, 0x9A, 0xCF, 0

  long_gdt_ram equ $-gdt_ram

  img_gdtr_ram:
        dw long_gdt_ram-1
        dd gdt_ram

  idt:
    EX0_DE  equ $-idt        	; Divide error
      dw  EX0_DE_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX1_DB  equ $-idt 			; Debug Exception
      dw  EX1_DB_HANDLER		
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX2_NMI  equ $-idt 			; Nonmaskarable external interrupt
      dw  EX2_NMI_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX3_BP  equ $-idt 			; Breakpoint
      dw  EX3_BP_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX4_OF  equ $-idt 			; Overflow
      dw  EX4_OF_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX5_BR  equ $-idt 			; Bound range exceed
      dw  EX5_BR_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX6_UD  equ $-idt         	; Invalid opcode
      dw  EX6_UD_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX7_NM  equ $-idt 			; Dev not available
      dw  EX7_NM_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX8_DF  equ $-idt 			; Double fault
      dw  EX8_DF_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX9_CSO  equ $-idt 			; Coprocessor segment overrun
      dw  EX9_CSO_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX10_TS equ $-idt 			; Invalid TSS
      dw  EX10_TS_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX11_NP  equ $-idt 			; Segment not present
      dw  EX11_NP_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX12_SS  equ $-idt 			; Stack segment fault
      dw  EX12_SS_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX13_GP  equ $-idt 			; General protection
      dw  EX13_GP_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX14_PF  equ $-idt 			; Page fault
      dw  EX14_PF_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX15  equ $-idt 			; Internal reserved
      dq  0x0

    EX16_MF  equ $-idt 			; Floating point error
      dw  EX16_MF_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX17_AC equ $-idt 			; Alignment check
      dw  EX17_AC_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX18_MC  equ $-idt 			; Machine check
      dw  EX18_MC_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX19_XM  equ $-idt 			; SIMD floating point exception
      dw  EX19_XM_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX20_VE  equ $-idt 			; Virtualization exception
      dw  EX20_VE_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8F
      dw  0x0

    EX_21_31   equ $-idt 		; Reserved
      times 11 dq 0x0

    ;EX_32_47        equ $-idt 	; User defined
    ;  times 16 dq 0x0

    EX32_ISR0_0x20	equ $-idt
      dw  ISR0_0x20_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX33_ISR1_0x21	equ $-idt
      dw  ISR1_0x21_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0   

    EX34_ISR2_0x22	equ $-idt
      dw  ISR2_0x22_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX35_ISR3_0x23	equ $-idt
      dw  ISR3_0x23_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX36_ISR4_0x24	equ $-idt
      dw  ISR4_0x24_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX37_ISR5_0x25	equ	$-idt
      dw ISR5_0x25_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX38_ISR6_0x26 	equ	$-idt
      dw  ISR6_0x26_HANDLER
      dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX39_ISR7_0x27	equ	$-idt
   	  dw ISR7_0x27_HANDLER
   	  dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX40_ISR8_0x28	equ	$-idt
      dw ISR8_0x28_HANDLER
   	  dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX41_ISR9_0x29	equ $-idt
      dw  ISR9_0x29_HANDLER
   	  dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX42_ISR10_0x2A  equ $-idt
      dw ISR10_0x2A_HANDLER
   	  dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX43_ISR11_0x2B	equ	$-idt
      dw ISR11_0x2B_HANDLER
   	  dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX44_ISR12_0x2C	equ	$-idt
      dw ISR12_0x2C_HANDLER
   	  dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX45_ISR13_0x2D	equ	$-idt
      dw ISR13_0x2D_HANDLER
   	  dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX46_ISR14_0x2E	equ	$-idt
      dw ISR14_0x2E_HANDLER
   	  dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0

    EX47_ISR15_0x2F	equ	$-idt
      dw ISR15_0x2F_HANDLER
   	  dw  cs_sel_ram
      db  0x0
      db  0x8E
      dw  0x0


    long_idt  equ $-idt

    img_idtr:
        dw long_idt-1
        dd idt




