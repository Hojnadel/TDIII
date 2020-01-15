/***Header http***/
const char gszHttpTemplate[] = {"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: %lu\r\nConnection: close\r\n\r\n%s"};


/***Http data***/
const char gszPageTemplate[] = {
"<!DOCTYPE html> \
<html> \
<head> \
    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /> \
    <meta http-equiv=\"refresh\" content=\"2\" /> \
    <meta charset=\"utf-8\" /> \
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"> \
    <title>UTN FRBA - Trabajo Práctico Técnicas Digitales 3 - 2do Cuatrimestre</title> \
    <link href=\"https://fonts.googleapis.com/css?family=Roboto\" rel=\"stylesheet\"> \
    <link href=\"https://fonts.googleapis.com/css?family=Roboto:100\" rel=\"stylesheet\"> \
    <link href=\"https://fonts.googleapis.com/css?family=Roboto:200\" rel=\"stylesheet\"> \
    <link href=\"https://fonts.googleapis.com/css?family=Roboto:300\" rel=\"stylesheet\"> \
    <link href=\"https://fonts.googleapis.com/css?family=Roboto:400\" rel=\"stylesheet\"> \
    <link href=\"https://fonts.googleapis.com/css?family=Roboto:500\" rel=\"stylesheet\"> \
    <link href=\"https://fonts.googleapis.com/css?family=Roboto:600\" rel=\"stylesheet\"> \
    <link href=\"https://fonts.googleapis.com/css?family=Roboto:700\" rel=\"stylesheet\"> \
    <link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css\" \
        integrity=\"sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm\" crossorigin=\"anonymous\"> \
    <style> \
        .measure-box { \
            border-radius: 10px; \
            padding: 20px 20px 20px 20px; \
            background-color: #cccccc; \
        } \
    </style> \
</head> \
<body style=\"background-color:black;\"> \
    <div class=\"row\"> \
        <div class=\"container\"> \
            <div style= \"background-color:transparent !important\" class=\"jumbotron bg-dark text-white\">\
                <h2>UTN FRBA - Técnicas Digitales 3 - Trabajo 2do cuatrimestre</h2> \
                <p> \
                    Alumno: %s \
                </p> \
                <p>\
                    Legajo: %s \
                </p> \
            </div> \
            <label class=\"alert alert-success\">La última medición exitosa fue tomada: %s</label> \
            <div class=\"row\"> \
                <div class=\"col-2\"> \
                </div> \
                <div class=\"col-2 measure-box text-center\"> \
                    <h4>Posición en X:</h4> \
                    <h5>%+05.2f°</h5> \
                </div> \
                <div class=\"col-1\"> \
                </div> \
                <div class=\"col-2 measure-box text-center\"> \
                    <h4>Posición en Y:</h4> \
                    <h5>%+05.2f°</h5> \
                </div> \
                <div class=\"col-1\"> \
                </div> \
                <div class=\"col-2 measure-box text-center\"> \
                    <h4>Posición en Z:</h4> \
                    <h5>%+05.2f°</h5> \
                </div> \
                <div class=\"col-1\"> \
                </div> \
            </div> \
        </div> \
        <script src=\"https://code.jquery.com/jquery-3.2.1.slim.min.js\" \
            integrity=\"sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN\" \
            crossorigin=\"anonymous\"></script> \
        <script src=\"https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js\" \
            integrity=\"sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q\" \
            crossorigin=\"anonymous\"></script> \
        <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js\" \
            integrity=\"sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl\" \
            crossorigin=\"anonymous\"></script> \
</body> \
</html>"
};



void handler_SIGCHLD(int sig){
    do{

    }while(waitpid(-1,NULL,WNOHANG)>0);
}

void error(const char *msg)
{
    perror(msg);
    exit(1);
}


void handler_SIGUSR1(int sig){

    chng_cnfg_flag = ON;

}


void load_configuration_file(void){
	FILE * fp;
	char aux[4][10];

	if((fp = fopen("config.txt","r"))==NULL)
		printf("[Error] | Error al abrir el archivo de Configuración.\n");
	else{
		for(int i=0; i<4; i++)
			fgets(aux[i], sizeof(aux),fp);

        pthread_mutex_lock(&mutex);

		backlog = atoi(aux[0]);
		max_conn = atoi(aux[1]);
		output_rate = atoi(aux[2]);
		max_vector = atoi(aux[3]);

        if(chng_cnfg_flag == ON){
            printf("[INFO] | pase el if de chng_cnfg_flag == ON\n");
            //free(x_vector);
            if((x_vector = (float*) realloc((void*)x_vector, sizeof(float)*max_vector)) == NULL){
                printf("[ERROR] | Memoria insuficiente\n");
                perror("ERROR:");
            }
            printf("[INFO] | hice el primer free\n");

            if((y_vector = (float*) realloc((void*)y_vector, sizeof(float)*max_vector)) == NULL){
                printf("[ERROR] | Memoria insuficiente\n");
                perror("ERROR:");
            }

            if((z_vector = (float*) realloc((void*)z_vector, sizeof(float)*max_vector)) == NULL){
                printf("[ERROR] | Memoria insuficiente\n");
                perror("ERROR:");
            }
        }

        pthread_mutex_unlock(&mutex);
		fclose(fp);
	}
	printf("CONFIGURACION ACTUAL:\nBacklog: %u\nConexiones maximas: %u\nOutput rate: %u\nmuestras del promedio: %u\n",backlog, max_conn, output_rate, max_vector );
}






void init_xyz_vectors(void){
    int i;

    if((x_vector = (float*) malloc(sizeof(float)*max_vector)) == NULL){
        printf("[ERROR] | Memoria insuficiente\n");
        perror("ERROR:");
    }

    if((y_vector = (float*) malloc(sizeof(float)*max_vector)) == NULL){
        printf("[ERROR] | Memoria insuficiente\n");
        perror("ERROR:");
    }

    if((z_vector = (float*) malloc(sizeof(float)*max_vector)) == NULL){
        printf("[ERROR] | Memoria insuficiente\n");
        perror("ERROR:");
    }
}


void init_semaphore(key_t* sem_key, int * sem_id, union semun * sem_un){

    if ((*sem_key = ftok(".", 'S')) == -1) {
        perror("ftok");
        exit(1);
    }

    if ((*sem_id = semget(*sem_key, 1, IPC_CREAT | 0600)) == -1){
        perror("semget");
        exit(1);
    }

    sem_un->val = 1;
    if (semctl(*sem_id, 0, SETVAL, *sem_un) == -1) {
        perror("semctl");
        exit(1);
    }

}


void init_shared_mem(key_t* shm_key, int * shm_id, void** shared_mem){

    if ((*shm_key = ftok(".", 'M')) == -1) {
        perror("ftok");
        exit(1);
    }    

    *shm_id = shmget( *shm_key, sizeof(struct shrmem_conn_counter_struct), 0600 | IPC_CREAT);
    if (*shm_id == -1) {
        perror("[ERROR] | Error al pedir memoria compartida\n");
        exit(EXIT_FAILURE);
    }
    printf("[INFO] | Shared memory creada\n");

    *shared_mem = shmat(*shm_id, NULL, 0);
    if (*shared_mem == (void *)-1) {
        perror("shmat in shrmem2_sysV failed");
        exit(EXIT_FAILURE);
    }
    printf("[INFO] | Shared memory attachada\n");
}


void semaphore_take(int* sem_id, struct sembuf * sem){
    sem->sem_op = -1; /* lock */
    if (semop(*sem_id, sem, 1) == -1) {
        perror("semop");
        exit(1);
    }
}

void semaphore_release(int* sem_id, struct sembuf * sem){
    sem->sem_op = 1; /* unlock */
    if (semop(*sem_id, sem, 1) == -1) {
        perror("semop");
        exit(1);
    }
}

void delete_semaphore(int* semid, union semun * sem_un){
    if (semctl(*semid, 0, IPC_RMID, *sem_un) == -1) {
        perror("semctl");
        exit(1);
    }  
}

void delete_shared_mem(void* shared_mem, int* shmid){
    if (shmdt(shared_mem) == -1) {
        perror("shmdt in shrmem2_sysV failed");
        exit(EXIT_FAILURE);
    }
      
    if (shmctl(*shmid, IPC_RMID, 0) == -1) {
        perror("shmctl in shrmem2_sysV failed");
        exit(EXIT_FAILURE);
    }  
}

void handler_SIGTERM(int sig){
    flag_sigterm = ON;
}