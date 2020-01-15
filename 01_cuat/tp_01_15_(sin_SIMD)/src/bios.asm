%define BREAKPOINT	xchg bx,bx

USE16

EXTERN  __bios_init 


section .reset

  start_reset:
    jmp inicio                        ;salto a inicio16
    times 16-($-start_reset) db 0     ;relleno con 0s


section .init

GLOBAL  cs_sel

  gdt:
  null_descriptor	equ	$-gdt
            db 0,0,0,0,0,0,0,0  ;Descriptor nulo
  ds_sel    equ $-gdt
            dw 0xFFFF     ;b15:0 del limite
            dw 0x0        ;b15:0 la base
            db 0          ;b23:16 la base
            db 0x92       ;datos con dpl 0
            db 0xCF       ;G=D=1 y b19:16 del limite.
            db 0          ;b31:24 de la base
  cs_sel    equ $-gdt
            dw 0xFFFF     ;b15:0 del limite
            dw 0x0        ;b15:0 la base
            db 0          ;b23:16 la base
            db 0x9A       ;código con dpl 0
            db 0xCF       ;G=D=1 y b19:16 del limite.
            db 0          ;b31:24 de la base

  long_gdt equ $-gdt

  img_gdtr:
        dw long_gdt-1
        dd gdt

  inicio:		  
   cli                  ;Deshabilito interrupciones
   cld                  ;Poner a cero flag de direccion para que las instrucciones de cadena operen con direcciones crecientes.
   call __bios_init 		;Cargo la bios de la pantalla

   db 0x66              ;Requerido para direcciones mayores
   lgdt  [cs:img_gdtr] 	;Cargo la gdt
   mov eax,cr0          ;Habiltación bit de modo protegido. 
   or eax,1
   mov cr0,eax
   jmp dword cs_sel:modo_proteg   ;jump far para cambiar el code segment
   
  USE32
  modo_proteg:
    mov ax,ds_sel   ;cargo el data segment
    mov ds, ax		  
    mov ss, ax	    ;cargo el stack segment   
    mov es, ax
    mov fs, ax
    mov gs, ax

    ;inicializo la pila en 0
EXTERN  __KERNEL_STACK_START
EXTERN  __KERNEL_STACK_SIZE
EXTERN  __KERNEL_STACK_END    
    xor eax,eax
    mov esp, __KERNEL_STACK_START   	;Fin de pila
    mov ecx, __KERNEL_STACK_SIZE		;Tamaño de pila
    loop_init_stack:
      push eax
      loop loop_init_stack
    mov esp, __KERNEL_STACK_END 				;inicializo el puntero de pila


;********************************************************************************;
;                      COMIENZO DEL COPIADO ROM --> RAM                          ;
;                                                                                ;
; - Se copian la rutina COPY a RAM                                               ;
; - Se copian todas las secciones con INDENTITY MAPPING                          ;
; - Se carga la IDT y la RAM_GDT												 ;
; - Comienzo la paginación: 													 ;
; 		* Se crean las tablas  													 ;
;		* Se entra en modo paginación (CR0.31 <= 1)								 ;
; - Copio las secciones paginadas                                                ;
;********************************************************************************;

; Hago la copia de COPY (IDTY MAPPING)
EXTERN __COPY_IN_ROM
EXTERN __COPY_IN_RAM
EXTERN __COPY_LEN
    push __COPY_IN_ROM    
    push __COPY_IN_RAM
    push __COPY_LEN
    ;utilizo la función copy que está en rom para copiarse en ram (0x0) 
    call __COPY_IN_ROM           
    ;Popeo lo que pushie
    pop eax
    pop eax
    pop eax

; Hago la copia de INIT_RAM (IDTY MAPPING)
EXTERN  __INIT_RAM
EXTERN  __INIT_RAM_LMA
EXTERN  __INIT_RAM_LEN
    push __INIT_RAM_LMA
    push __INIT_RAM
    push __INIT_RAM_LEN
    call __COPY_IN_RAM
    pop eax
    pop eax
    pop eax

; Copio el resto de las secciones que tienen IDENTITY MAPPING a RAM
EXTERN  init_ram_itty_map
    call init_ram_itty_map                 


;Cargo en la IDT y la GDT de RAM (SysTables están cargadas con ITTY MAPPING)
EXTERN  img_gdtr_ram
EXTERN  img_idtr
EXTERN  cs_sel_ram
EXTERN  ds_sel_ram
EXTERN 	TSS_sel

  lgdt [cs:img_gdtr_ram]
  lidt [cs:img_idtr]

  ;cargo la TSS
  mov ax, TSS_sel
  ltr ax
  ;jmp dword cs_sel_ram:gdt_ram
  ;gdt_ram:

;Cargo las tablas de paginación de cada directorio
EXTERN  page_memory_task0
EXTERN  page_memory_task1
EXTERN  page_memory_task2

    call page_memory_task2
    call page_memory_task1
    call page_memory_task0

EXTERN __PAGE_DIRECTORY_ADDR_TASK2
EXTERN __PAGE_DIRECTORY_ADDR_TASK1
EXTERN __PAGE_DIRECTORY_ADDR_TASK0
EXTERN 	init_ram_task2
EXTERN 	init_ram_task1
EXTERN 	init_ram_task0

;Copio las secciones que no tenían IDTTY MAPPING
    mov eax, __PAGE_DIRECTORY_ADDR_TASK2	; Ativo paginación con el directorio de TASK2 
    mov cr3, eax
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

	call init_ram_task2
	call init_tss_T2
	
    mov eax, __PAGE_DIRECTORY_ADDR_TASK1	; Cambio al directirio de TASK1
    mov cr3, eax

	call init_ram_task1
	call init_tss_T1

	mov eax, __PAGE_DIRECTORY_ADDR_TASK0	; Cambio al directorio de TASK0
    mov cr3, eax

    call init_ram_task0
	call init_tss_T0
EXTERN  __pic_configure
EXTERN  __pit_configure
EXTERN  pic_enable_interrupt
  ;inicializo los PICS con interrupciones deshabilitadas
  call __pic_configure
  
  ;inicializo el PIT
  call __pit_configure

  ;habilito interrupciones del pic de teclado y timer
  call pic_enable_interrupt

  ;habilito el flag de interrupciones
  sti


;Empiezo a correr el nucleo desde ram

;EXTERN __KERNEL_START_RAM
  ;jmp __KERNEL_START_RAM
EXTERN task0
EXTERN FLAG_TASK0
EXTERN task_running
	mov byte [task_running], FLAG_TASK0
  	jmp task0





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


;Inicialización de la tss_T2
EXTERN tss_T2
init_tss_T2:
    mov dword [tss_T2+OFFSET_ESP0], __TASK2_KERNEL_STACK_END
    mov dword [tss_T2+OFFSET_SS0], ds_sel_ram
    mov dword [tss_T2+OFFSET_ESP], __TASK2_USER_STACK_END
    mov dword [tss_T2+OFFSET_EIP], __TASK2_TEXT_LINEAR_ADDR
    mov dword [tss_T2+OFFSET_CS], cs_sel_ram_pl3
    mov dword [tss_T2+OFFSET_DS], ds_sel_ram_pl3
    mov dword [tss_T2+OFFSET_ES], ds_sel_ram_pl3
    mov dword [tss_T2+OFFSET_FS], ds_sel_ram_pl3
    mov dword [tss_T2+OFFSET_GS], ds_sel_ram_pl3
    mov dword [tss_T2+OFFSET_SS], ds_sel_ram_pl3
    mov dword [tss_T2+OFFSET_EAX], 0
    mov dword [tss_T2+OFFSET_EBX], 0
    mov dword [tss_T2+OFFSET_ECX], 0
    mov dword [tss_T2+OFFSET_EDX], 0
    mov dword [tss_T2+OFFSET_EDI], 0
    mov dword [tss_T2+OFFSET_ESI], 0
    mov dword [tss_T2+OFFSET_EBP], 0
    mov dword [tss_T2+OFFSET_EFLAGS], 0x200    ;interrupciones
    mov dword [tss_T2+OFFSET_CR3], __PAGE_DIRECTORY_ADDR_TASK2
    ret

;Inicialización de la tss_T1
EXTERN tss_T1
init_tss_T1:
    mov dword [tss_T1+OFFSET_ESP0], __TASK1_KERNEL_STACK_END
    mov dword [tss_T1+OFFSET_SS0], ds_sel_ram
    mov dword [tss_T1+OFFSET_ESP], __TASK1_USER_STACK_END
    mov dword [tss_T1+OFFSET_EIP], __TASK1_TEXT_LINEAR_ADDR
    mov dword [tss_T1+OFFSET_CS], cs_sel_ram_pl3
    mov dword [tss_T1+OFFSET_DS], ds_sel_ram_pl3
    mov dword [tss_T1+OFFSET_ES], ds_sel_ram_pl3
    mov dword [tss_T1+OFFSET_FS], ds_sel_ram_pl3
    mov dword [tss_T1+OFFSET_GS], ds_sel_ram_pl3
    mov dword [tss_T1+OFFSET_SS], ds_sel_ram_pl3
    mov dword [tss_T1+OFFSET_EAX], 0
    mov dword [tss_T1+OFFSET_EBX], 0
    mov dword [tss_T1+OFFSET_ECX], 0
    mov dword [tss_T1+OFFSET_EDX], 0
    mov dword [tss_T1+OFFSET_EDI], 0
    mov dword [tss_T1+OFFSET_ESI], 0
    mov dword [tss_T1+OFFSET_EBP], 0
    mov dword [tss_T1+OFFSET_EFLAGS], 0x200    ;interrupciones
    mov dword [tss_T1+OFFSET_CR3], __PAGE_DIRECTORY_ADDR_TASK1
    ret

;Inicialización de la tss_T0
EXTERN tss_T0
init_tss_T0:
    mov dword [tss_T0+OFFSET_ESP0], __TASK0_KERNEL_STACK_END
    mov dword [tss_T0+OFFSET_SS0], ds_sel_ram
    mov dword [tss_T0+OFFSET_ESP], __TASK0_USER_STACK_END
    mov dword [tss_T0+OFFSET_EIP], __TASK0_TEXT_LINEAR_ADDR
    mov dword [tss_T0+OFFSET_CS], cs_sel_ram_pl3
    mov dword [tss_T0+OFFSET_DS], ds_sel_ram_pl3
    mov dword [tss_T0+OFFSET_ES], ds_sel_ram_pl3
    mov dword [tss_T0+OFFSET_FS], ds_sel_ram_pl3
    mov dword [tss_T0+OFFSET_GS], ds_sel_ram_pl3
    mov dword [tss_T0+OFFSET_SS], ds_sel_ram_pl3
    mov dword [tss_T0+OFFSET_EAX], 0
    mov dword [tss_T0+OFFSET_EBX], 0
    mov dword [tss_T0+OFFSET_ECX], 0
    mov dword [tss_T0+OFFSET_EDX], 0
    mov dword [tss_T0+OFFSET_EDI], 0
    mov dword [tss_T0+OFFSET_ESI], 0
    mov dword [tss_T0+OFFSET_EBP], 0
    mov dword [tss_T0+OFFSET_EFLAGS], 0x200    ;interrupciones
    mov dword [tss_T0+OFFSET_CR3], __PAGE_DIRECTORY_ADDR_TASK0
    ret