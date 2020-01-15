void * exit_program(void * arg){

	struct clear_resources_struct cr;

	pthread_detach(pthread_self());

	memcpy(&cr,arg,sizeof(cr));

	while(1){
		if(flag_sigterm == ON){
			pthread_mutex_lock(&mutex);					//Tomo el mutex para que nadie más corra
			semaphore_take(cr._semid, cr._sem);				//Tomo el semaforo para que nadie más corra

			printf("\n");
			close(cr._sockfd);
			printf("[INFO] | Socket cerrado\n");
			free(x_vector); free(y_vector); free(z_vector);
			printf("[INFO] | Memoria de los vecores xyz liberada\n");
			delete_semaphore(cr._semid, cr._semun);
			printf("[INFO] | Semaforo de kernel destruido\n");
		    delete_shared_mem(cr._sharedmem, cr._shmid);
		    printf("[INFO] | Memoria compartida de kernel liberada\n");
		    pthread_cancel(cr._acqid);
		    printf("[INFO] | Thread adxl_data_acquierer cancelado\n");
		    pthread_cancel(cr._avgid);
		    printf("[INFO] | Thread averaging cancelado\n");
		    pthread_cancel(cr._configid);
		    printf("[INFO] | Thread configuration_change_thread cancelado\n");
		    pthread_mutex_destroy(&mutex);
		    printf("[INFO] | Mutex destruido\n");
		    exit(EXIT_SUCCESS);
		}
		usleep(250000);
	}
}