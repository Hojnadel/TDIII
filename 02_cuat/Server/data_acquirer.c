#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/unistd.h>

#include "data_acquirer.h"

void * adxl_data_acquirer(void * x){

	int sz, i;
	short gx = 0, gy = 0, gz =0;

	pthread_detach(pthread_self());
	
	printf("Iniciando el dispositivo\n");
	ADXL345_config();


	while(1){
		ADXL345_get_data(&gx, &gy, &gz);

		//printf("Posicion X: %i, %f,  %.4f\n", gx, gx-X_AXIS_OFFSET, (gx-X_AXIS_OFFSET)*X_AXIS_GAIN);	//Para calibracion de eje X
		//printf("Posicion Y: %i, %f,  %.4f\n", gy, gy-Y_AXIS_OFFSET, (gy-Y_AXIS_OFFSET)*Y_AXIS_GAIN);	//Para calibracion de eje Y
		//printf("Posicion Z: %i, %f,  %.4f\n", gz, gz-Z_AXIS_OFFSET, (gz-Z_AXIS_OFFSET)*Z_AXIS_GAIN);	//Para calibracion de eje Y
		printf("Datos Crudos:\nPosicion X: %+05.2f \tPosicion Y = %+05.2f \tPosicion Z = %+05.2f\n", \
			(gx-X_AXIS_OFFSET)*X_AXIS_GAIN, (gy-Y_AXIS_OFFSET)*Y_AXIS_GAIN, (gz-Z_AXIS_OFFSET)*Z_AXIS_GAIN);
		
		pthread_mutex_lock(&mutex);
		x_vector[vector_index] = (gx-X_AXIS_OFFSET)*X_AXIS_GAIN;
		y_vector[vector_index] = (gy-Y_AXIS_OFFSET)*Y_AXIS_GAIN;
		z_vector[vector_index] = (gz-Z_AXIS_OFFSET)*Z_AXIS_GAIN;
		if(++vector_index >= max_vector)
			vector_index = 0;
		for(i=0; i<max_vector; i++)
			printf("%5.2f ",x_vector[i]);
		printf("\n");
		pthread_mutex_unlock(&mutex);

		usleep(DATA_ACQ_RATE);

	}

}


void ADXL345_config(void){
	int fd, sz;
	char rx_buffer[BUFFER_RX_LEN]={0};

	if((fd=open(SPI_PATH, O_RDWR))<0){
		printf("No se pudo abrir el dispositivo\n");
		perror("ERROR: ");
	}

	sz = write(fd, rx_buffer, sizeof(rx_buffer));
	close(fd);
}

void ADXL345_get_data(short * x, short * y, short * z){
	int fd, sz;
	char rx_buffer[BUFFER_RX_LEN]={0};

	if((fd=open(SPI_PATH, O_RDWR))<0){
		printf("No se pudo abrir el dispositivo\n");
		perror("ERROR: ");
	}

	sz = read(fd, rx_buffer,sizeof(rx_buffer));
	if(rx_buffer[6] == 0xE5){
		*x = rx_buffer[1]<<8 | rx_buffer[0];
		*y = rx_buffer[3]<<8 | rx_buffer[2];
		*z = rx_buffer[5]<<8 | rx_buffer[4];
	}
	else
		printf("Datos obtnidos no validos\n");
	close(fd);
}