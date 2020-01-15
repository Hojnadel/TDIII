use32

GLOBAL	infinit_loop

section .kernel
	
	infinit_loop:
		hlt
		jmp infinit_loop
