EXTERN __COPY_IN_ROM
EXTERN __COPY_IN_RAM

EXTERN  __STACK_START
EXTERN  __STACK_SIZE
EXTERN  __STACK_END

EXTERN  __ROUTINES_LENGTH
EXTERN  __ROUTINES_START_ROM  ;Origen
EXTERN  __ROUTINES_START_RAM  ;Destino

EXTERN __KERNEL_START_RAM



section .reset
  start_reset:
    USE16
    jmp inicio                        ;salto a inicio16
    times 16-($-start_reset) db 0     ;relleno con 0s


section .init


  ; Descriptores de la GDT
  gdt:
            db 0,0,0,0,0,0,0,0  ;Descriptor nulo
  ds_sel    equ $-gdt
            db 0xFF, 0xFF, 0, 0, 0, 0x92, 0xCF, 0
  cs_sel    equ $-gdt
            db 0xFF, 0xFF, 0, 0, 0, 0x9A, 0xCF, 0

  long_gdt equ $-gdt

  img_gdtr:
        dw long_gdt-1
        dd gdt



  inicio:		  
   cli       ;Deshabilito interrupciones
   db 0x66            ;Requerido para direcciones mayores
   lgdt  [cs:img_gdtr] ;que 0x00FFFFFFF. 
   mov eax,cr0        ;Habiltación bit de modo protegido. 
   or eax,1
   mov cr0,eax
   jmp dword cs_sel:modo_proteg   ;jump far para cambiar el code segment
   
  USE32
  modo_proteg:
    mov ax,ds_sel    ;cargo el data segment
    mov ds,ax		  

    ;inicializo la pila en 0
    mov ss, eax               ;cargo el stack segment   
    xor eax,eax
    mov esp, __STACK_START    ;inicializo el puntero de pila
    mov ecx, __STACK_SIZE
    loop_init_stack:
      push eax
      loop loop_init_stack
    mov esp, __STACK_END

EXTERN __ROUTINES_START_ROM

    ;Voy a llamar a copy para copiar rutinas. Pusheo fuente, destino y tamaño.
    push __ROUTINES_START_ROM    
    push __ROUTINES_START_RAM
    push __ROUTINES_LENGTH
    call __COPY_IN_ROM           ;copy: copio en ram 0x0 las rutinas (por ahora solo el copy)
    ;Popeo lo que pushie
        												xchg bx,bx

    pop eax
    pop eax
    pop eax
    													xchg bx,bx
    push __ROUTINES_START_ROM    
    push __KERNEL_START_RAM
    push __ROUTINES_LENGTH
    call __COPY_IN_RAM 

        												xchg bx,bx


    push eax
    jmp $
  

			

	



 

