%define MASTER_PIC_CMD_PORT   0x20
%define MASTER_PIC_DATA_PORT  0x21

%define SLAVE_PIC_CMD_PORT    0xA0
%define SLAVE_PIC_DATA_PORT   0xA1

SECTION .init
GLOBAL 	__pic_configure
GLOBAL	pic_enable_interrupt
USE32

;************************************************************************************************************************;
;                                                                                                                        ;
;                 https://en.wikibooks.org/wiki/X86_Assembly/Programmable_Interrupt_Controller#Masking                   ;
;                                                                                                                        ;
;************************************************************************************************************************;

__pic_configure:

   mov al, 0x11
   out MASTER_PIC_CMD_PORT, al
   out SLAVE_PIC_CMD_PORT, al

   mov al, 0x20                           ; empieza en la interrupción 0x20 = 32
   out MASTER_PIC_DATA_PORT, al
   mov al, 0x28                           ; empieza en la interrupción 0x28 = 40
   out SLAVE_PIC_DATA_PORT, al

   mov al, 0x4
   out MASTER_PIC_DATA_PORT, al
   mov al, 0x2
   out SLAVE_PIC_DATA_PORT, al

   mov al, 0x1
   out MASTER_PIC_DATA_PORT, al
   mov al, 0x1
   out SLAVE_PIC_DATA_PORT, al


   ; Deshabilito las interrupciones
   mov al, 0xFF
   out MASTER_PIC_DATA_PORT, al
   out SLAVE_PIC_DATA_PORT, al

   ret




pic_enable_interrupt:
	;habilito la ex 0x20 y 0x21 - int 0x0 e int 0x1
	mov al, 0x3			;al 0x0000 0011
	xor al,0xFF			;al 0x1111 1100
	out MASTER_PIC_DATA_PORT, al
	ret

;********************************************************************************************************************;
;                                                   Masking                                                          ;
;Normally, reading from the data port returns the IMR register (see above), and writing to it sets the register.     ;
;We can use this to set which IRQs should be ignored. For example, to disable IRQ 6 (floppy controller) from firing: ;
;                                                                                                                    ;                                                                                                                    ;
;in ax, 0x21                                                                                                         ;
;or ax, (1 << 6)                                                                                                     ;
;out 0x21, ax                                                                                                        ;
;                                                                                                                    ;
;In the same way, to disable IRQ 12 (mouse controller):                                                              ;
;                                                                                                                    ;
;in ax, 0xA1                                                                                                         ;
;or ax, (1 << 4)   ;IRQ 12 is actually IRQ 4 of PIC2                                                                 ;
;out 0xA1, ax                                                                                                        ;
;********************************************************************************************************************;

;********************************************************************************************************************;
;IRQ 0 ‒ system timer
;IRQ 1 — keyboard controller
;IRQ 3 — serial port COM2
;IRQ 4 — serial port COM1
;IRQ 5 — line print terminal 2
;IRQ 6 — floppy controller
;IRQ 7 — line print terminal 1
;IRQ 8 — RTC timer
;IRQ 12 — mouse controller
;IRQ 13 — math co-processor
;IRQ 14 — ATA channel 1
;IRQ 15 — ATA channel 2
;********************************************************************************************************************;