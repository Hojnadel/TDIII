#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/unistd.h>

#include "ADXL345.h"

#define BUFFER_TX_LEN		2
#define	BUFFER_RX_LEN		7

#define SPI_PATH		"/dev/my_SPI_Driver"
#define X_AXIS_OFFSET	7.5
#define Y_AXIS_OFFSET	-4.5
#define Z_AXIS_OFFSET	231.0

#define X_AXIS_GAIN		0.349514563
#define Y_AXIS_GAIN		0.341555977
#define Z_AXIS_GAIN		0.355029586

#define	READ_DELAY		350		//mayor a Tclk * 16 = 1/50kHz * 16 = 320us

#define	INITIAL_OUTPUT_RATE 	125000

typedef unsigned int uint32_t;


int main(void){

	int fd, sz;
	char rx_buffer[BUFFER_RX_LEN]={0};
	short gx = 0, gy = 0, gz =0;

	if((fd=open(SPI_PATH, O_RDWR))<0){
		printf("No se pudo abrir el dispositivo\n");
		perror("ERROR: ");
		return EXIT_FAILURE;
	}

	sz = write(fd, rx_buffer, sizeof(rx_buffer));

	while(1){

		sz = read(fd, rx_buffer,sizeof(rx_buffer));

	    if(rx_buffer[6] == 0xE5){
			gx = rx_buffer[1]<<8 | rx_buffer[0];
			gy = rx_buffer[3]<<8 | rx_buffer[2];
			gz = rx_buffer[5]<<8 | rx_buffer[4];

			printf("%i %i %i\n",gz,gy,gz );
		}
		sleep(1);

	}

	return 0;

}
