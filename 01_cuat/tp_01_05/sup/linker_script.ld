__STACK_START = 0x1FFFB000;
__STACK_SIZE = 0x4000;							/*Tamanio de pila 16kb*/
__STACK_END = __STACK_START + __STACK_SIZE; 	/*Fin de pila 0x1FFFF000*/


MEMORY
{
	ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0xFFFF0000
	rom(rx) : ORIGIN = 0xFFFF0000, LENGTH = 0xFFF0
	rom_reset (rx) : ORIGIN = 0xFFFFFFF0, LENGTH = 0x10		/*Preservo de que el codigo de rom no me pise el codigo de reset*/
}



SECTIONS
{	
	
	.nucleo 0x00300000 :
		{ __KERNEL_START_RAM = .;

		} AT >rom
		

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
		__OTRA_RUTINA_QUE_VIENE_DESPUES_DE_COPY = .;
		*(.rutinas);  /*Voy a colocar todo lo que encuentre en sections rutinas en los asm*/
		__ROUTINES_LENGTH = . - __ROUTINES_START_RAM;
		} AT >rom


	. = 0xFFFFFFF0;
	.reset :
		{*(.reset)} AT >rom_reset
}






/* Lo que es con . es dirección virtual*/
/* Lo que es con AT es dirección de carga*/