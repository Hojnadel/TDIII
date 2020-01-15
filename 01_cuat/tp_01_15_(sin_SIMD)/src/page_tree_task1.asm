%define BREAKPOINT	xchg bx,bx

%define	page_att 	[ebp+4]
%define	page_table_att 	[ebp+8]
%define	sect_len	 	[ebp+12]
%define	phy_addr	 	[ebp+16]
%define lin_addr		[ebp+20]
%define page_table_addr	[ebp+24]
%define pag_dir_addr    [ebp+28]

__DIR_PAGE_ATT_KERNEL_RW        EQU 0x3
__DIR_PAGE_ATT_USER_RW          EQU 0x7
__DIR_PAGE_ATT_USER_R           EQU 0x5
__PAGE_TABLE_ATT_KERNEL_RW      EQU 0x3
__PAGE_TABLE_ATT_USER_RW		EQU	0x7
__PAGE_TABLE_ATT_USER_R         EQU 0x5

EXTERN  __paginate

section	.init_RAM

;************************************************************************************ ;
;__paginate: Función que pagina una sección. Recibe:                                  ;
;1_Dirección de la tabla de página                                                    ;
;2_Dirección lineal de la sección                                                     ;
;3_Dirección física de la sección                                                     ;
;4_Longitud de la sección (para calcular la cantidad de páginas que se necesitan)     ;
;5_Atributos de la tabla de página                                                    ;
;6_Atributos de la página                                                             ;
;*************************************************************************************;
GLOBAL	page_memory_task1
page_memory_task1:
; Limpio el Directorio y las Tablas de paginación
EXTERN  __PAGE_DIRECTORY_ADDR_TASK1
EXTERN  __PAGE_TABLE_0x000_TASK1_ADDR
EXTERN  __PAGE_TABLE_0x001_TASK1_ADDR
EXTERN  __PAGE_TABLE_0x07F_TASK1_ADDR
EXTERN  __PAGE_TABLE_0x3FF_TASK1_ADDR
EXTERN  __PAGE_TABLES_SIZE
    mov edi, __PAGE_DIRECTORY_ADDR_TASK1
    mov ecx, __PAGE_TABLES_SIZE
    shr ecx, 2
    xor eax, eax
  .ciclo_ini_dir_pag:
      mov [edi], eax
      add edi, 4
      dec ecx
      jnz .ciclo_ini_dir_pag

; ******************************Comienzo la paginación********************************;

;Paginación de .init
;Dirección lineal:  0xFFFF0000  
; 0x 1111 1111 11|11 1111 0000 | 0x0 0x0 0x0 
;   3 F   F  | 3  F   0   
;Indice de directorio : 0x3FF
;Indice de tabla:     0x3F0 / 0x3F1 
;Tamaño de la sección: 0x1405 Bytes ==> 2 páginas
EXTERN  __INIT_LINEAR_ADDR
EXTERN  __INIT_LEN
EXTERN  __INIT_PHYSICAL_ADDR
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x3FF_TASK1_ADDR
    push __INIT_LINEAR_ADDR
    push __INIT_PHYSICAL_ADDR
    push __INIT_LEN
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax


;Paginación de .isr
;Dirección física: 0x00000000
;Dirección lineal: 0x00000000
; 0x 0000 0000 00|00 0000 0000 | 0x0 0x0 0x0
;   0 0 0  | 0  0 0 
;Indice de directorio : 0x000
;Indice de tabla:     0x000
;Tamaño de la sección: 0xC9 Bytes ==> 1 página
EXTERN  __ISR_LINEAR_ADDR
EXTERN  __ISR_PHYSICAL_ADDR
EXTERN  __ISR_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x000_TASK1_ADDR
    push __ISR_LINEAR_ADDR
    push __ISR_PHYSICAL_ADDR
    push __ISR_LEN
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax


;Paginación del buffer de video
;Dirección física: 0x000B8000
;Dirección lineal: 0x00010000
; 0x 0000 0000 00|00 0001 0000 | 0x0 0x0 0x0
;   	0 	0 	0| 0	1	0   
;Indice de directorio : 0x000
;Indice de tabla:     0x10 / 0x11 / 0x12 / 0x13 / 0x14 / 0x15 / 0x16 / 0x17
;Tamaño de la sección: 0x7FFF Bytes ==> 8 páginas
EXTERN  __VIDEO_BUFFER_LINEAR_ADDR
EXTERN  __VIDEO_BUFFER_PHYSICAL_ADDR
EXTERN  __VIDEO_BUFFER_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x000_TASK1_ADDR
    push __VIDEO_BUFFER_LINEAR_ADDR
    push __VIDEO_BUFFER_PHYSICAL_ADDR
    push __VIDEO_BUFFER_LEN
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax


;Paginación de SysTables
;Dirección lineal: 0x00100000
;Dirección física: 0x00100000
; 0x 0000 0000 00|01 0000 0000 | 0x0 0x0 0x0
;   	0 0 	0| 1  0 	0 
;Indice de directorio : 0x000
;Indice de tabla:     0x100
;Tamaño de la sección: 0xC9 Bytes ==> 1 página

EXTERN  __SYS_TABLES_LINEAR_ADDR
EXTERN  __SYS_TABLES_PHYSICAL_ADDR
EXTERN  __SYS_TABLES_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x000_TASK1_ADDR
    push __SYS_TABLES_LINEAR_ADDR
    push __SYS_TABLES_PHYSICAL_ADDR
    push __SYS_TABLES_LEN
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax



;Paginación de PageTables
;Dirección lineal: 0x00110000
;Dirección física: 0x00110000
; 0x 0000 0000 00|01 0001 0000 | 0x0 0x0 0x0
;   	0 0 	0| 1  1 	0 
;Indice de directorio : 0x000
;Indice de tabla:     0x110
;Tamaño de la sección: __PAGE_TABLES_SIZE (5*0x1000 = 20kB) ==> 5 páginas
EXTERN  __PAGE_TABLES_LINEAR_ADDR
EXTERN  __PAGE_TABLES_PHYISICAL_ADDR
EXTERN  __PAGE_TABLES_SIZE
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x000_TASK1_ADDR
    push __PAGE_TABLES_LINEAR_ADDR
    push __PAGE_TABLES_PHYISICAL_ADDR
    push __PAGE_TABLES_SIZE
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax



;Paginación de copy
;Dirección lineal: 0x00200000
;Dirección física: 0x00200000
; 0x 0000 0000 00|02 0000 0000 | 0x0 0x0 0x0
;         0 0 0  | 2 0      0   
;Indice de directorio : 0x000
;Indice de tabla:       0x200
;Tamaño de la sección: 0x15 Bytes ==> 1 página
EXTERN  __COPY_LINEAR_ADDR
EXTERN  __COPY_PHYSICAL_ADDR
EXTERN  __COPY_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x000_TASK1_ADDR
    push __COPY_LINEAR_ADDR
    push __COPY_PHYSICAL_ADDR
    push __COPY_LEN
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax

;Paginación de routines
;Dirección lineal: 0x00210000
;Dirección física: 0x00210000
; 0x 0000 0000 00|10 0001 0000 | 0x0 0x0 0x0
;         0 0 0  | 2 1      0   
;Indice de directorio : 0x000
;Indice de tabla:       0x210
;Tamaño de la sección: 0x3b6 Bytes ==> 1 página
EXTERN  __ROUTINES_LINEAR_ADDR
EXTERN  __ROUTINES_PHYSICAL_ADDR
EXTERN  __ROUTINES_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x000_TASK1_ADDR
    push __ROUTINES_LINEAR_ADDR
    push __ROUTINES_PHYSICAL_ADDR
    push __ROUTINES_LEN
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax


;Paginación de init_RAM
;Dirección lineal: 0x00220000
;Dirección fisica: 0x00220000
; 0x 0000 0000 00|10 0010 0000 | 0x0 0x0 0x0
;         0 0 0  | 2  2     0   
;Indice de directorio : 0x000
;Indice de tabla:       0x220
;Tamaño de la sección: 0x23B Bytes ==> 1 página
EXTERN  __INIT_RAM_LINEAR_ADDR
EXTERN  __INIT_RAM_PHYSICAL_ADDR
EXTERN  __INIT_RAM_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x000_TASK1_ADDR
    push __INIT_RAM_LINEAR_ADDR
    push __INIT_RAM_PHYSICAL_ADDR
    push __INIT_RAM_LEN
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax


;Paginación de kernel
;Dirección física: 0x00500000
;Dirección lineal: 0x00500000
; 0x 0000 0000 01|01 0000 0000 | 0x0 0x0 0x0
;         0 0 1  | 1  0     0   
;Indice de directorio : 0x001
;Indice de tabla:       0x100
;Tamaño de la sección: 0x35 Bytes ==> 1 página
EXTERN  __KERNEL_LINEAR_ADDR
EXTERN  __KERNEL_PHYSICAL_ADDR
EXTERN  __KERNEL_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x001_TASK1_ADDR
    push __KERNEL_LINEAR_ADDR
    push __KERNEL_PHYSICAL_ADDR
    push __KERNEL_LEN
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax

;Paginación de la digit table
;Dirección física: 0x00510000
;Dirección lineal: 0x00510000
; 0x 0000 0000 01|01 0001 0000 | 0x0 0x0 0x0
;         0 0 1  | 1  1     0   
;Indice de directorio : 0x001
;Indice de tabla:       0x110
;Tamaño de la sección: 0xffff Bytes ==> 16 páginas
EXTERN  __DIGIT_TABLE_LINEAR_ADDR
EXTERN  __DIGIT_TABLE_PHYSICAL_ADDR
EXTERN  __DIGIT_TABLE_SIZE
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x001_TASK1_ADDR
    push __DIGIT_TABLE_LINEAR_ADDR
    push __DIGIT_TABLE_PHYSICAL_ADDR
    push __DIGIT_TABLE_SIZE
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax

;Paginación de task_TEXT
;Dirección física: 0x00521000
;Dirección lineal: 0x00610000
; 0x 0000 0000 01|10 0001 0000 | 0x0 0x0 0x0
;         0 0 1  | 2  1     0   
;Indice de directorio : 0x001
;Indice de tabla:       0x0210
;Tamaño de la sección: 0x3C Bytes ==> 1 página
EXTERN  __TASK1_TEXT_LINEAR_ADDR
EXTERN  __TASK1_TEXT_PHYSICAL_ADDR
EXTERN  __TASK1_TEXT_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x001_TASK1_ADDR
    push __TASK1_TEXT_LINEAR_ADDR
    push __TASK1_TEXT_PHYSICAL_ADDR
    push __TASK1_TEXT_LEN
    push __DIR_PAGE_ATT_USER_R
    push __PAGE_TABLE_ATT_USER_R
    call __paginate
    times 7 pop eax


;Paginación de task_BSS
;Dirección física: 0x00522000
;Dirección lineal: 0x00611000
; 0x 0000 0000 01|10 0001 0001 | 0x0 0x0 0x0
;         0 0 1  | 2  1     1   
;Indice de directorio : 0x001
;Indice de tabla:       0x211
;Tamaño de la sección: 0x9 Bytes ==> 1 página
EXTERN  __TASK1_BSS_LINEAR_ADDR
EXTERN  __TASK1_BSS_PHYSICAL_ADDR
EXTERN  __TASK1_BSS_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x001_TASK1_ADDR
    push __TASK1_BSS_LINEAR_ADDR
    push __TASK1_BSS_PHYSICAL_ADDR
    push __TASK1_BSS_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 7 pop eax


;Paginación de task_DATA
;Dirección física: 0x00523000
;Dirección lineal: 0x00612000
; 0x 0000 0000 01|10 0001 0010 | 0x0 0x0 0x0
;         0 0 1  | 2  1     2   
;Indice de directorio : 0x001
;Indice de tabla:       0x212
;Tamaño de la sección: 0x9 Bytes ==> 1 página
EXTERN  __TASK1_DATA_LINEAR_ADDR
EXTERN  __TASK1_DATA_PHYSICAL_ADDR
EXTERN  __TASK1_DATA_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x001_TASK1_ADDR
    push __TASK1_DATA_LINEAR_ADDR
    push __TASK1_DATA_PHYSICAL_ADDR
    push __TASK1_DATA_LEN
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 7 pop eax


;Paginación de datos
;Dirección física: 0x005E0000
;Dirección lineal: 0x005E0000
; 0x 0000 0000 01|01 1110 0000 | 0x0 0x0 0x0
;         0 0 1  | 1  E     0   
;Indice de directorio : 0x001
;Indice de tabla:       0x1E0
;Tamaño de la sección: 0x0 Bytes ==> 1 página
EXTERN  __DATA_LINEAR_ADDR
EXTERN  __DATA_PHYSICAL_ADDR
EXTERN  __DATOS_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x001_TASK1_ADDR
    push __DATA_LINEAR_ADDR
    push __DATA_PHYSICAL_ADDR
    push __DATOS_LEN
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax


;Paginación de BSS
;Dirección física: 0x005F0000
;Dirección lineal: 0x005F0000
; 0x 0000 0000 01|01 1111 0000 | 0x0 0x0 0x0
;         0 0 1  | 1  F     0   
;Indice de directorio : 0x001
;Indice de tabla:       0x1F0
;Tamaño de la sección: 0x36 Bytes ==> 1 página
EXTERN  __BSS_LINEAR_ADDR
EXTERN  __BSS_PHYSICAL_ADDR
EXTERN  __BSS_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x001_TASK1_ADDR
    push __BSS_LINEAR_ADDR
    push __BSS_PHYSICAL_ADDR
    push __BSS_LEN
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax

;Paginación de STACK
;Dirección física: 0x1FFFB000
;Dirección lineal: 0x1FFFB000
; 0x 0001 1111 11|11 1111 1011 | 0x0 0x0 0x0
;         0 7 F  | 3  F     B   
;Indice de directorio : 0x07F
;Indice de tabla:       0x3FB
;Tamaño de la sección: 0x1000 Bytes ==> 1 páginas
EXTERN  __KERNEL_STACK_LINEAR_ADDR
EXTERN  __KERNEL_STACK_PHYSICAL_ADDR
EXTERN  __KERNEL_STACK_SIZE
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x07F_TASK1_ADDR
    push __KERNEL_STACK_LINEAR_ADDR
    push __KERNEL_STACK_PHYSICAL_ADDR
    push __KERNEL_STACK_SIZE
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax


;Paginación de TASK1_KERNEL_STACK
;Dirección física: 0x1FFFA000
;Dirección lineal: 0x00614000
; 0x 0000 0000 01|10 0001 0100 | 0x0 0x0 0x0
;         0 0 1  | 2  1     4   
;Indice de directorio : 0x001
;Indice de tabla:       0x214
;Tamaño de la sección: 0x1000 Bytes ==> 1 página
EXTERN  __TASK1_KERNEL_STACK_LINEAR_ADDR
EXTERN  __TASK1_KERNEL_STACK_PHYSICAL_ADDR
EXTERN  __TASK1_KERNEL_STACK_SIZE
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x001_TASK1_ADDR
    push __TASK1_KERNEL_STACK_LINEAR_ADDR
    push __TASK1_KERNEL_STACK_PHYSICAL_ADDR
    push __TASK1_KERNEL_STACK_SIZE
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax

;Paginación de TASK1_USER_STACK
;Dirección física: 0x1FFFE000
;Dirección lineal: 0x00613000
; 0x 0000 0000 01|10 0001 0011 | 0x0 0x0 0x0
;         0 0 1  | 2  1     3   
;Indice de directorio : 0x001
;Indice de tabla:       0x213
;Tamaño de la sección: 0x1000 Bytes ==> 1 página
EXTERN  __TASK1_USER_STACK_LINEAR_ADDR
EXTERN  __TASK1_USER_STACK_PHYSICAL_ADDR
EXTERN  __TASK1_USER_STACK_SIZE
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x001_TASK1_ADDR
    push __TASK1_USER_STACK_LINEAR_ADDR
    push __TASK1_USER_STACK_PHYSICAL_ADDR
    push __TASK1_USER_STACK_SIZE
    push __DIR_PAGE_ATT_USER_RW
    push __PAGE_TABLE_ATT_USER_RW
    call __paginate
    times 7 pop eax


;Paginación de RESET
;Dirección física: 0xFFFFFFF0
;Dirección lineal: 0xFFFFFFF0
; 0x 1111 1111 11|11 1111 1111 | 0xF 0xF 0x0
;       3  F  F  | 3  F     F   
;Indice de directorio : 0x3FF
;Indice de tabla:       0x3FF
;Tamaño de la sección: 0x10 Bytes ==> 1 página
EXTERN  __RESET_LINEAR_ADDR
EXTERN  __RESET_PHYSICAL_ADDR
EXTERN  __RESET_LEN
    push __PAGE_DIRECTORY_ADDR_TASK1
    push __PAGE_TABLE_0x3FF_TASK1_ADDR
    push __RESET_LINEAR_ADDR
    push __RESET_PHYSICAL_ADDR
    push __RESET_LEN
    push __DIR_PAGE_ATT_KERNEL_RW
    push __PAGE_TABLE_ATT_KERNEL_RW
    call __paginate
    times 7 pop eax

	ret



