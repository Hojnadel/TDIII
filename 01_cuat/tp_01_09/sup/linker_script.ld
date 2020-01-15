__STACK_START = 0x1FFFB000;
__STACK_SIZE = 0x4000;							/*Tamanio de pila 16kb*/
__STACK_END = __STACK_START + __STACK_SIZE; 	/*Fin de pila 0x1FFFF000*/

__DIGIT_TABLE_START = 0x00310000;
__DIGIT_TABLE_SIZE = 0xFFFF;					/* 64kb*/
__DIGIT_TABLE_END = __DIGIT_TABLE_START + __DIGIT_TABLE_SIZE;

__VIDEO_BUFFER_START = 0xB8000;
__VIDEO_BUFFER_LEN = 0x7FFF;
__VIDEO_BUFFER_END = __VIDEO_BUFFER_START + __VIDEO_BUFFER_LEN;


MEMORY
{
	ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0xFFFF0000
	rom(rx) : ORIGIN = 0xFFFF0000, LENGTH = 0xFFF0
	rom_reset (rx) : ORIGIN = 0xFFFFFFF0, LENGTH = 0x10		/*Preservo de que el codigo de rom no me pise el codigo de reset*/
}



SECTIONS
{	
	. = 0xFFFF0000;
	.init : 
		{*(.init)} AT >rom

	
	.isr 0x00000000 :
		{
		__ISR_START_RAM = .;
		__ISR_START_ROM = LOADADDR(.isr);
		*(.isr);
		} AT >rom


	.sys_tables 0x00100000 :
		{
		__SYS_TABLES_RAM = .;
		__SYS_TABLES_ROM = LOADADDR(.sys_tables);
		*(.sys_tables);
		} AT >rom

	.copy 0x00200000 :
		{
		__COPY_IN_RAM = .;
		__COPY_IN_ROM = LOADADDR(.copy);
		*(.copy)
		} AT >rom


	.rutinas 0x00210000 :
		{
		__ROUTINES_START_RAM = .; /*Guardamos la VMA del inicio de rutinas en ram, la vamos a usar en nuestro programa*/
		__ROUTINES_START_ROM = LOADADDR(.rutinas);
		/*__COPY_IN_ROM = __ROUTINES_START_ROM;
		__COPY_IN_RAM = .;
		bin/rutinas.elf(.copy); /*Solamente la que esta en copy.elf*/
		__KEYBOARD_ROUTINE = .;
		*(.rutinas_keyboard);  /*Voy a colocar todo lo que encuentre en sections rutinas en los asm*/
		} AT >rom


	.kernel 0x00300000 :
		{ 
		__KERNEL_START_RAM = .; 
		__KERNEL_START_ROM = LOADADDR(.kernel);
		*(.nucleo);
		} AT >rom

	.digit_table 0x00310000 :
		{}

	.task1 0x00320000 :
		{
		__TASK1_START_RAM = .;
		__TASK1_START_ROM = LOADADDR(.task1);
		*(.task1);
		} AT >rom
	
	.datos 0x003E0000 :
		{
		__DATOS_START_RAM = .;
		__DATOS_START_ROM = LOADADDR(.datos);
		*(.datos);
		} AT >rom

	.bss 0x003F0000 :
		{
		__BSS_START = .;
		*(.bss);
		} AT >rom

	. = 0xFFFFFFF0;
	.reset :
		{*(.reset)} AT >rom_reset
}

__ISR_LEN = SIZEOF(.isr);
__KERNEL_LEN = SIZEOF(.kernel);
__ROUTINES_LEN = SIZEOF(.rutinas);
__COPY_LEN = SIZEOF(.copy);
__SYS_TABLES_LEN = SIZEOF(.sys_tables);
__TASK1_LEN = SIZEOF(.task1);
__DATOS_LEN = SIZEOF(.datos);
__BSS_LEN = SIZEOF(.bss);




/* Lo que es con . es dirección virtual*/
/* Lo que es con AT es dirección de carga*/