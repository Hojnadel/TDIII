EXTERN	polling_0x64

section .kernel
	xor eax,eax			;Para no dejar el kernel vacío

	;Salto a la rutina de polling de teclado
	jmp polling_0x64
