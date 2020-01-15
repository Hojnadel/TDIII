#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/unistd.h>

#include "data_acquirer.h"
#include "ADXL345.h"



typedef unsigned int uint32_t;


void adxl_data_acquirer(void){

	int fd, sz;
	int read_value = 0;
	uint32_t output_rate = INITIAL_OUTPUT_RATE;
	char rx_buffer[BUFFER_RX_LEN]={0};
	char tx_buffer[BUFFER_TX_LEN]={0};
	char gx0 = 0, gx1 = 0;
	char gy0 = 0, gy1 = 0;
	char gz0 = 0, gz1 = 0;
	short gx = 0, gy = 0, gz =0;
	short addr_x0 = 0, addr_x1 = 0;
	short addr_y0 = 0, addr_y1 = 0;
	short addr_z0 = 0, addr_z1 = 0;
	char x0_buffer[BUFFER_TX_LEN], x1_buffer[BUFFER_TX_LEN];
	char y0_buffer[BUFFER_TX_LEN], y1_buffer[BUFFER_TX_LEN];
	char z0_buffer[BUFFER_TX_LEN], z1_buffer[BUFFER_TX_LEN];		
	short aux = 0;

	if((fd=open(SPI_PATH, O_RDWR))<0){
		printf("No se pudo abrir el dispositivo\n");
		perror("ERROR: ");
		return EXIT_FAILURE;
	}

	printf("Pidiendo identificacion del dispositivo\n");
	aux = (DEV_ID<<8)|BIT_READ;
	memcpy(tx_buffer, &aux, sizeof(aux));
	//printf("Mandando %02X\n",aux);
	
	sz = write(fd, tx_buffer, sizeof(tx_buffer));
	//usleep(READ_DELAY);
	sz = read(fd, rx_buffer, sizeof(rx_buffer));
	memcpy(&read_value, rx_buffer, sizeof(rx_buffer));
	printf("ADXL345 ID: \t0x%02X\n", read_value);

	usleep(output_rate);

	printf("Iniciando el dispositivo\n");

	aux = (BW_RATE<<8) | BIT_WRITE | BIT_RATE_6_25HZ; 	//Configuro el dataout rate
	memcpy(tx_buffer, &aux, sizeof(tx_buffer));
	sz = write(fd, tx_buffer, sizeof(tx_buffer));

	aux = (POWER_CTL<<8) | BIT_WRITE | BIT_MESURE_ON;
	memcpy(tx_buffer, &aux, sizeof(tx_buffer));
	sz = write(fd, tx_buffer, sizeof(tx_buffer)); //Habilito el mesure

	usleep(output_rate);
	
	/*Seteo la transmision para leer los registros del eje X*/
	addr_x0 = (DATAX0<<8) | BIT_READ | MB_BIT;
	addr_x1 = (DATAX1<<8) | BIT_READ;
	memcpy(x0_buffer, &addr_x0, sizeof(x0_buffer));
	memcpy(x1_buffer, &addr_x1, sizeof(x1_buffer));

	/*Seteo la transmision para leer los registros del eje Y*/
	addr_y0 = (DATAY0<<8) | BIT_READ;
	addr_y1 = (DATAY1<<8) | BIT_READ;
	memcpy(y0_buffer, &addr_y0, sizeof(y0_buffer));
	memcpy(y1_buffer, &addr_y1, sizeof(y1_buffer));

	/*Seteo la transmision para leer los registros del eje Y*/
	addr_z0 = (DATAZ0<<8) | BIT_READ;
	addr_z1 = (DATAZ1<<8) | BIT_READ;
	memcpy(z0_buffer, &addr_z0, sizeof(z0_buffer));
	memcpy(z1_buffer, &addr_z1, sizeof(z1_buffer));

	while(1){
		/*Obtengo los datos del eje X*/
		sz = write(fd, x1_buffer, sizeof(x1_buffer));
		sz = read(fd, rx_buffer, sizeof(rx_buffer));
		//memcpy(&gx1, rx_buffer, sizeof(rx_buffer));
		gx = rx_buffer[0]<<8;
		sz = write(fd, x0_buffer, sizeof(x0_buffer));
		sz = read(fd, rx_buffer, sizeof(rx_buffer));
		//memcpy(&gx0, rx_buffer, sizeof(rx_buffer));
		//gx = (gx1<<8) | gx0;
		gx |= rx_buffer[0];

		/*Obtengo los datos del eje Y*/
		sz = write(fd, y1_buffer, sizeof(y1_buffer));
		//usleep(READ_DELAY);
		sz = read(fd, rx_buffer, sizeof(rx_buffer));
		gy = rx_buffer[0]<<8;
		//memcpy(&gy1, rx_buffer, sizeof(rx_buffer));
		sz = write(fd, y0_buffer, sizeof(y0_buffer));
		//usleep(READ_DELAY);
		sz = read(fd, rx_buffer, sizeof(rx_buffer));
		//memcpy(&gy0, rx_buffer, sizeof(rx_buffer));
		//gy = (gy1<<8) | gy0;
		gy |= rx_buffer[0];

		/*Obtengo los datos del eje Z*/
		sz = write(fd, z1_buffer, sizeof(z1_buffer));
		//usleep(READ_DELAY);
		sz = read(fd, rx_buffer, sizeof(rx_buffer));
		//memcpy(&gz1, rx_buffer, sizeof(rx_buffer));
		gz = rx_buffer[0]<<8;
		sz = write(fd, z0_buffer, sizeof(z0_buffer));
		//usleep(READ_DELAY);
		sz = read(fd, rx_buffer, sizeof(rx_buffer));
		//memcpy(&gz0, rx_buffer, sizeof(rx_buffer));
		//gz = (gz1<<8) | gz0;
		gz |= rx_buffer[0];

		//printf("Posicion X: %i, %f,  %.4f\n", gx, gx-X_AXIS_OFFSET, (gx-X_AXIS_OFFSET)*X_AXIS_GAIN);	//Para calibracion de eje X
		//printf("Posicion Y: %i, %f,  %.4f\n", gy, gy-Y_AXIS_OFFSET, (gy-Y_AXIS_OFFSET)*Y_AXIS_GAIN);	//Para calibracion de eje Y
		//printf("Posicion Z: %i, %f,  %.4f\n", gz, gz-Z_AXIS_OFFSET, (gz-Z_AXIS_OFFSET)*Z_AXIS_GAIN);	//Para calibracion de eje Y
		printf("Posicion X: %+05.2f \tPosicion Y = %+05.2f \tPosicion Z = %+05.2f\n", (gx-X_AXIS_OFFSET)*X_AXIS_GAIN, (gy-Y_AXIS_OFFSET)*Y_AXIS_GAIN, (gz-Z_AXIS_OFFSET)*Z_AXIS_GAIN);
		usleep(output_rate);

	}

}
