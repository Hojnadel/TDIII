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
EXTERN  __STACK_START
EXTERN  __STACK_SIZE
EXTERN  __STACK_END    
    xor eax,eax
    mov esp, __STACK_START    ;inicializo el puntero de pila
    mov ecx, __STACK_SIZE
    loop_init_stack:
      push eax
      loop loop_init_stack
    mov esp, __STACK_END


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
  lgdt [cs:img_gdtr_ram]
  lidt [cs:img_idtr]


;Comienzo a cargar las tablas de paginación
EXTERN  page_memory
    call page_memory              ; Rutina que pagina todas las secciones


; Ativo paginación
EXTERN __PAGE_DIRECTORY_ADDR
  
    mov eax, __PAGE_DIRECTORY_ADDR
    mov cr3, eax
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax


; Copio las secciones a RAM que no tiene ITTY MAPPING
EXTERN 	init_ram_mapped
	call init_ram_mapped


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

EXTERN __KERNEL_START_RAM
  jmp __KERNEL_START_RAM
  


