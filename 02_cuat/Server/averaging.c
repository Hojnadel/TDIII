
void * averaging(void * null){

	int i, or;

	pthread_detach(pthread_self());

	while(1){

		pthread_mutex_lock(&mutex);

		avg_x = 0;
		avg_y = 0;
		avg_z = 0;

		or = output_rate;

		for(i=0; i<max_vector; i++){
			avg_x += x_vector[i];
			avg_y += y_vector[i];
			avg_z += z_vector[i];
		}
		
		avg_x /= max_vector;
		avg_y /= max_vector;
		avg_z /= max_vector;
		pthread_mutex_unlock(&mutex);

		// printf("El promedio en X es %+5.2f\n", avg_x);
		printf("\nDatos Promediadios:\nPosicion X: %+05.2f \tPosicion Y = %+05.2f \tPosicion Z = %+05.2f\n\n", avg_x, avg_y, avg_z);

		sleep(or);
	}

}