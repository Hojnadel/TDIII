
void * conf_change_thread(void* arg){

	pthread_detach(pthread_self());

	while(1){
		if(chng_cnfg_flag == ON){
			printf("[INFO] | Se llamo a SIGUSR1 y se estan cambiando las configuraciones\n");
			load_configuration_file();
			chng_cnfg_flag = OFF;
		}
		sleep(5);
	}
}
