__VIDEO_BUFFER_LINEAR_ADDR = 0x00010000;
__VIDEO_BUFFER_START = __VIDEO_BUFFER_LINEAR_ADDR;
__VIDEO_BUFFER_LEN = 0x8000;
__VIDEO_BUFFER_END = __VIDEO_BUFFER_START + __VIDEO_BUFFER_LEN -1;

__PAGE_TABLES_LINEAR_ADDR = 0x00110000;
__PAGE_DIRECTORY_ADDR = __PAGE_TABLES_LINEAR_ADDR;
__PAGE_TABLE_0x000_ADDR = __PAGE_DIRECTORY_ADDR + 0x1000;
__PAGE_TABLE_0x001_ADDR = __PAGE_DIRECTORY_ADDR + 0x2000;
__PAGE_TABLE_0x07F_ADDR = __PAGE_DIRECTORY_ADDR + 0x3000;
__PAGE_TABLE_0x3FF_ADDR = __PAGE_DIRECTORY_ADDR + 0x4000;
__PAGE_TABLES_QTY_FIX = 4;
/*Para paginar toda la RAM (0x0000 0000 a 0x1FFF FFFF) necesito tener tablas de paginación desde 0x000 hasta 0x07F,
que son 127 páginas. Debo agregarle el bloque del directorio y lo de la ROM (tabla 0x3FF), siendo en total 129 páginas*/
__PAGE_TABLES_QTY_MAX = 127 + 1; 	/* 127 tablas de para RAM y una tabla para la ROM*/
__PAGE_TABLES_SIZE = (__PAGE_TABLES_QTY_MAX + 1) * 0x1000;
__PHYSICAL_ADDR_NEW_PAGES = 0x08000000;

__DIGIT_TABLE_LINEAR_ADDR = 0x00310000;
__DIGIT_TABLE_START = __DIGIT_TABLE_LINEAR_ADDR;
__DIGIT_TABLE_SIZE = 0x10000;					/* 64kb*/
__DIGIT_TABLE_END = __DIGIT_TABLE_START + __DIGIT_TABLE_SIZE - 1;

__STACK_LINEAR_ADDR = 0x1FFFB000;
__STACK_START = __STACK_LINEAR_ADDR;
__STACK_SIZE = 0x3000;								/*Tamanio de pila 16kb*/
__STACK_END = __STACK_START + __STACK_SIZE - 1; 	/*Fin de pila 0x1FFFDFFF*/

__TASK1_STACK_LINEAR_ADDR = 0x00413000;
__TASK1_STACK_START = __TASK1_STACK_LINEAR_ADDR;
__TASK1_STACK_SIZE = 0x2000;							
__TASK1_STACK_END = __TASK1_STACK_START + __TASK1_STACK_SIZE - 1; 	


/****************PHYSICAL ADDRESS SECTIONS****************/
__ISR_PHYSICAL_ADDR 			= 	0x00000000;
__VIDEO_BUFFER_PHYSICAL_ADDR 	= 	0x000B8000;
__SYS_TABLES_PHYSICAL_ADDR 		= 	0x00100000;
__PAGE_TABLES_PHYISICAL_ADDR 	= 	0x00110000;
__COPY_PHYSICAL_ADDR			=	0x00200000;
__ROUTINES_PHYSICAL_ADDR 		=	0x00210000;
__INIT_RAM_PHYSICAL_ADDR		= 	0x00220000;
__KERNEL_PHYSICAL_ADDR			= 	0X00400000;
__DIGIT_TABLE_PHYSICAL_ADDR 	= 	0x00310000;
__TASK1_TEXT_PHYSICAL_ADDR		=	0x00420000;
__TASK1_BSS_PHYSICAL_ADDR 		=	0x00421000;
__TASK1_DATA_PHYSICAL_ADDR		=	0x00422000;
__DATA_PHYSICAL_ADDR 			= 	0x004E0000;
__BSS_PHYSICAL_ADDR 			= 	0x004F0000;
__STACK_PHYSICAL_ADDR 			= 	0x1FFFB000;
__TASK1_STACK_PHYSICAL_ADDR 	= 	0x1FFFE000;
__INIT_PHYSICAL_ADDR 			=	0xFFFF0000;
__RESET_PHYSICAL_ADDR 			=	0xFFFFFFF0;
/********************************************************/

MEMORY
{
	ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0xFFFF0000
	rom(rx) : ORIGIN = 0xFFFF0000, LENGTH = 0xFFF0
	rom_reset (rx) : ORIGIN = 0xFFFFFFF0, LENGTH = 0x10		/*Preservo de que el codigo de rom no me pise el codigo de reset*/
}



SECTIONS
{	
	.init 0xFFFF0000 : 
		{	__INIT_LINEAR_ADDR = .;
			*(.init)
		} AT >rom


	.isr 0x00000000 :
		{
		__ISR_LINEAR_ADDR = .;
		__ISR_START_RAM = __ISR_LINEAR_ADDR;
		__ISR_START_ROM = LOADADDR(.isr);
		*(.isr);
		} AT >rom


	.sys_tables 0x00100000 :
		{
		__SYS_TABLES_LINEAR_ADDR = .;
		__SYS_TABLES_RAM = __SYS_TABLES_LINEAR_ADDR;
		__SYS_TABLES_ROM = LOADADDR(.sys_tables);
		*(.sys_tables);
		} AT >rom

	.copy 0x00200000 :
		{
		__COPY_LINEAR_ADDR = .;
		__COPY_IN_RAM = __COPY_LINEAR_ADDR;
		__COPY_IN_ROM = LOADADDR(.copy);
		*(.copy)
		} AT >rom


	.routines 0x00210000 :
		{
		__ROUTINES_LINEAR_ADDR = .;
		__ROUTINES_START_RAM = __ROUTINES_LINEAR_ADDR; 
		__ROUTINES_START_ROM = LOADADDR(.routines);
		__KEYBOARD_ROUTINES = .;
		*(.keyboard_routines);  /*Voy a colocar todo lo que encuentre en sections routines en los asm*/
		__SCREEN_ROUTINES = .;
		*(.screen_routines);
		__PAGINATION_ROUTINES = .;
		*(.pagination_routines);
		} AT >rom

	.init_RAM 0x00220000 :
		{
			__INIT_RAM_LINEAR_ADDR = .;
			__INIT_RAM = __INIT_RAM_LINEAR_ADDR;
			__INIT_RAM_LMA = LOADADDR(.init_RAM);
			*(.init_RAM);
		} AT >rom

	.kernel 0x00400000 :
		{ 
		__KERNEL_LINEAR_ADDR = .;
		__KERNEL_START_RAM = __KERNEL_LINEAR_ADDR; 
		__KERNEL_START_ROM = LOADADDR(.kernel);
		*(.nucleo);
		} AT >rom

	.task1_TEXT 0x00510000 :
		{
		__TASK1_TEXT_LINEAR_ADDR = .;
		__TASK1_TEXT_START_RAM = __TASK1_TEXT_LINEAR_ADDR;
		__TASK1_TEXT_START_ROM = LOADADDR(.task1_TEXT);
		*(.task1_TEXT);
		} AT >rom

	.task1_BSS 0x00511000 :
		{
		__TASK1_BSS_LINEAR_ADDR = .;
		__TASK1_BSS_START_RAM = __TASK1_BSS_LINEAR_ADDR;
		__TASK1_BSS_START_ROM = LOADADDR(.task1_BSS);
		*(.task1_BSS);
		} AT >rom	

	.task1_DATA 0x00512000 :
		{
		__TASK1_DATA_LINEAR_ADDR = .;
		__TASK1_DATA_START_RAM = __TASK1_DATA_LINEAR_ADDR;
		__TASK1_DATA_START_ROM = LOADADDR(.task1_DATA);
		*(.task1_DATA);
		} AT >rom	

	.datos 0x004E0000 :
		{
		__DATA_LINEAR_ADDR = .;
		__DATOS_START_RAM = __DATA_LINEAR_ADDR;
		__DATOS_START_ROM = LOADADDR(.datos);
		*(.datos);
		} AT >rom

	.bss 0x004F0000 :
		{
		__BSS_LINEAR_ADDR = .;
		__BSS_START = __BSS_LINEAR_ADDR;
		*(.bss);
		} AT >rom

	.reset 0xFFFFFFF0:
		{
		__RESET_LINEAR_ADDR = .;
			*(.reset)
		} AT >rom_reset
}

__ISR_LEN 			= SIZEOF(.isr);
__SYS_TABLES_LEN 	= SIZEOF(.sys_tables);
__COPY_LEN 			= SIZEOF(.copy);
__ROUTINES_LEN 		= SIZEOF(.routines);
__INIT_RAM_LEN 		= SIZEOF(.init_RAM);
__KERNEL_LEN 		= SIZEOF(.kernel);
__TASK1_TEXT_LEN 	= SIZEOF(.task1_TEXT);
__TASK1_BSS_LEN 	= SIZEOF(.task1_BSS);
__TASK1_DATA_LEN 	= SIZEOF(.task1_DATA);
__DATOS_LEN 		= SIZEOF(.datos);
__BSS_LEN 			= SIZEOF(.bss);
__INIT_LEN 			= SIZEOF(.init);
__RESET_LEN 		= SIZEOF(.reset);




/* Lo que es con . es dirección virtual*/
/* Lo que es con AT es dirección de carga*/