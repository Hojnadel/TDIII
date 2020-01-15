EXTERN	polling_0x64
EXTERN digit_table_index

EXTERN 	img_gdtr_ram
EXTERN	img_idtr

EXTERN	__pic_configure

use32

section .kernel
	xchg bx,bx

	;cargo en ram la gdt y la idt
	lgdt [cs:img_gdtr_ram]
	lidt [cs:img_idtr]

	;inicializo los PICS con interrupciones deshabilitadas
	call __pic_configure

	;habilito el flag de interrupciones
	sti

	;inicializo en 0 la variable de .datos
	xor eax,eax
	mov [digit_table_index], ax

	;Salto a la rutina de polling de teclado
	jmp polling_0x64
