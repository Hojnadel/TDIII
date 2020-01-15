#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/unistd.h>

#include "server.h"




int main (void){

	char key;
	int status;
	pthread_t adxl_thd_id;

	if(((status = pthread_create(&adxl_thd_id, NULL, adxl_data_acquirer, NULL)) != 0){
		printf("[ERROR] | No se pudo ejecutar el thread adxl_get_data.\n");
		perror("ERROR:");
		return status;
	}

	while(1){
		if(key=getchar() == 'q'){
			pthread_detach(adxl_thd_id);
			return EXIT_SUCCESS;
		}
		usleep(1000000);
	}
}