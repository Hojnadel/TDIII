#ifndef __SPI_DRIVER_FUNC_H__
#define __SPI_DRIVER_FUNC_H__


// DEFINES
#define	CS_LINE_DOWN	0
#define CS_LINE_UP		1



// PROTOTYPES
void print_status_registers(volatile void*);
short mi_atoh(char*);

#endif