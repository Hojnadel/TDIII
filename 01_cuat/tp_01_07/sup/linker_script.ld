__STACK_START = 0x1FFFB000;
__STACK_SIZE = 0x4000;							/*Tamanio de pila 16kb*/
__STACK_END = __STACK_START + __STACK_SIZE; 	/*Fin de pila 0x1FFFF000*/

__DIGIT_TABLE_START = 0x00310000;
__DIGIT_TABLE_SIZE = 0xFFFF;					/* 64kb*/
__DIGIT_TABLE_END = __DIGIT_TABLE_START + __DIGIT_TABLE_SIZE;


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

	
	.rutinas 0x00000000 :
		{
		__ROUTINES_START_RAM = .; /*Guardamos la VMA del inicio de rutinas en ram, la vamos a usar en nuestro programa*/
		__ROUTINES_START_ROM = LOADADDR(.rutinas);
		__COPY_IN_ROM = __ROUTINES_START_ROM;
		__COPY_IN_RAM = .;
		bin/rutinas.elf(.copy); /*Solamente la que esta en copy.elf*/
		__KEYBOARD_ROUTINE = .;
		*(.rutinas);  /*Voy a colocar todo lo que encuentre en sections rutinas en los asm*/
		*(.isr);
		} AT >rom


	.sys_tables 0x00100000 :
		{
		__SYS_TABLES_RAM = .;
		__SYS_TABLES_ROM = LOADADDR(.sys_tables);
		*(.sys_tables);
		} AT >rom


	.kernel 0x00300000 :
		{ 
		__KERNEL_START_RAM = .; 
		__KERNEL_START_ROM = LOADADDR(.kernel);
		*(.nucleo);
		} AT >rom

	.digit_table 0x00310000 :
		{

		}

	
	.datos 0x003E0000 :
		{*(.datos)} AT >rom


	. = 0xFFFFFFF0;
	.reset :
		{*(.reset)} AT >rom_reset
}

__KERNEL_SIZE = SIZEOF(.kernel);
__ROUTINES_LENGTH = SIZEOF(.rutinas);
__SYS_TABLES_LEN = SIZEOF(.sys_tables);





/* Lo que es con . es dirección virtual*/
/* Lo que es con AT es dirección de carga*/