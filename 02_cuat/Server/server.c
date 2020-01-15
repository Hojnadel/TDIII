#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <sys/wait.h>
#include <time.h>
#include <sys/shm.h>
#include <sys/sem.h>


#include "server.h"

#include "globals.c"
#include "data_acquirer.c"
#include "averaging.c"
#include "server_utils.c"
#include "config_change_th.c"
#include "exit_program_th.c"




int main (int argc, char *argv[]){

    //General variables
	int status, i;	

	//Time variables
	time_t timer;
	struct tm *ptime;
	char time_string[LEN_MAX];

    //Shared mem y sempaphores variables
    void *shared_mem = (void *) 0;
    struct shrmem_conn_counter_struct *shrd_counter;
    int shm_id, sem_id;
    key_t shm_key, sem_key;
    union semun sem_un;
    struct sembuf sem = {0, -1, 0};  /* arrancar en lock */

    //Server variables
    short port;
    int n, rc;
    int sockfd, newsockfd;
    char buffer[BUF_LEN];
    char outBuffer[BUF_LEN];
    char pageBuffer[BUF_LEN];
    struct sockaddr_in serv_addr, cli_addr;
    socklen_t clilen;

	//Threads variables
	pthread_t adxl_thd_id;
	pthread_t averaging_thd_id;
    pthread_t config_change_thd_id;
    pthread_t exit_thd_id;
	pthread_mutex_init(&mutex, NULL);

    struct clear_resources_struct cr;



    /*Comprobación de argumentos*/
    if (argc < 2){
        port = htons(atoi("8081"));
    }
    else if(atoi(argv[1]) < 1024){
        printf("El puerto debe ser mayor que 1024. Por defecto se asignara 8081.\n");
        port = htons(atoi("8081"));
    }
    else{
        port = htons(atoi(argv[1]));
    }

    printf("\n[INFO] | Port to try: %i\n",ntohs(port));
	
    load_configuration_file();                                         //Cargo el archivo de texto con la configuración
	
    init_xyz_vectors();                                                 //Pido memoria dinamica para los vectores
    for (i = 0; i < max_vector; i++){
        x_vector[i] = 0; y_vector[i] = 0; z_vector[i] = 0;
    }

    init_semaphore(&sem_key, &sem_id, &sem_un);                         //Inicializo el semáforo de kernel para shared memory

    init_shared_mem(&shm_key, &shm_id, &shared_mem);                    //Inicializo la memoria compartida

    shrd_counter = (struct shrmem_conn_counter_struct *) shared_mem;    //Vinculo la memoria compartida con mi estructura
    shrd_counter->conn_counter=0;

    /*** Asigo el handler del SIGCHLD y SIGUSR1***/
    signal(SIGCHLD, handler_SIGCHLD);
    signal(SIGUSR1, handler_SIGUSR1);
    signal(SIGTERM, handler_SIGTERM);
    signal(SIGINT, handler_SIGTERM);

    //Comienzan las tareas del servidor//

    /*** Creo el Socket***/    
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0))<0){
        printf("[ERROR] | Error opening socket");
        perror("[ERROR] | ");
        flag_sigterm = ON;
    }

    /*** Configuración del server***/
    bzero((char *)&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = port;
    clilen = sizeof(cli_addr);

    
   // if (bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0){
   //      printf("\n\n[ERROR] | Error on binding");
   //      perror("[ERROR] | ");
   //      flag_sigterm = ON;
   // }

    /*** Conecto el programa con el puerto ***/
    while(bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr))){
        serv_addr.sin_port = htons(ntohs(serv_addr.sin_port)+1);
    }
    printf("\n [INFO] | El que se usará: %i\n\n", ntohs(serv_addr.sin_port));
    
    sleep(2);

    /*** Indico el backlog ***/
    if(listen(sockfd, backlog)){
        printf("[ERROR] | Error on listen");
        perror("[ERROR] | ");
        flag_sigterm = ON;
    }


    /***** Comienzo a lanzar los threads *****/
    if((status = pthread_create(&adxl_thd_id, NULL, adxl_data_acquirer, NULL)) != 0){
        printf("[ERROR] | No se pudo ejecutar el thread adxl_data_acquirer.\n");
        perror("[ERROR]:");
        delete_semaphore(&sem_id, &sem_un);
        delete_shared_mem(shared_mem, &shm_id);
        return status;
    }

    if((status = pthread_create(&averaging_thd_id, NULL, averaging, NULL)) != 0){
        printf("[ERROR] | No se pudo ejecutar el thread averaging.\n");
        perror("[ERROR]:");
        delete_semaphore(&sem_id, &sem_un);
        delete_shared_mem(shared_mem, &shm_id);
        return status;
    }

    if((status = pthread_create(&config_change_thd_id, NULL, conf_change_thread, NULL)) != 0){
        printf("[ERROR] | No se pudo ejecutar el thread conf_change_thread.\n");
        perror("[ERROR]:");
        delete_semaphore(&sem_id, &sem_un);
        delete_shared_mem(shared_mem, &shm_id);
        return status;
    }

    //Cargo la estructura que cierra el programa correctamente
    cr._sockfd = sockfd;
    cr._sharedmem = shared_mem;
    cr._shmid = &shm_id;
    cr._semid = &sem_id;
    cr._semun = &sem_un;
    cr._sem = &sem;
    cr._acqid = adxl_thd_id;
    cr._avgid = averaging_thd_id;
    cr._configid = config_change_thd_id;

    if((status = pthread_create(&exit_thd_id, NULL, exit_program, (void*) &cr)) != 0){
        printf("[ERROR] | No se pudo ejecutar el thread exit_thread.\n");
        perror("[ERROR] |");
        delete_semaphore(&sem_id, &sem_un);
        delete_shared_mem(shared_mem, &shm_id);
        return status;
    }


    while(1){

        semaphore_take(&sem_id, &sem);
        if(shrd_counter->conn_counter < max_conn){                                      //Chequeo que no haya superado las conexiones máximas
            semaphore_release(&sem_id, &sem);

            /*** Bloquea el server con accept en espera de nuevos pedidos***/
            if((newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, &clilen))<0){  //Acepto clientes
                delete_semaphore(&sem_id, &sem_un);
                delete_shared_mem(shared_mem, &shm_id);
                error("[ERROR] | Error on accept");
            }

            semaphore_take(&sem_id, &sem);
            shrd_counter->conn_counter++;                                               //Aumento el contador de conexiones activas
            semaphore_release(&sem_id, &sem);

            rc = fork();

            if(rc == 0){                                                                //Soy el hijo

                close(sockfd);                                                          //Cierro el socket principal (server) heredado

                bzero(buffer, sizeof(buffer));                                          //Limpio el buffer de transmisión

                if(read(newsockfd, buffer, sizeof(buffer))<0)                         //Leo si llegó algo por el socket cliente
                    error("[ERROR] | Error reading from socket\n");

                timer=time(NULL);                                                       //Tomo la hora del sistema
                ptime=localtime(&timer);                                                //Convierto la hora a formato de estructura
                strftime(time_string, LEN_MAX, FMT_AAAAMMDDHHMMSS, ptime);              //Convierto la hora a formato cadena de caracteres

                sprintf(pageBuffer, gszPageTemplate, MY_NAME, MY_LEGAJO, time_string, avg_x, avg_y, avg_z); //Agrego el cuerpo HTML y las referencias a un buffer auxiliar
                sprintf(outBuffer, gszHttpTemplate, strlen(pageBuffer), pageBuffer);    //Agrego el buffer auxiliar y el header HTML al buffer de salida

                if(write(newsockfd, outBuffer, strlen(outBuffer))<0)                    //Escribo por el socket
                    error("[ERROR] | Error writing in socket\n");
                

                close(newsockfd);                                                       //Cierro el socket cliente

                semaphore_take(&sem_id, &sem);   
                shrd_counter->conn_counter--;                                           //Descuento las conexiones activas
                semaphore_release(&sem_id, &sem);

                exit(EXIT_SUCCESS);
            }
            else{                                                                       //Else de padre/hijo
                close(newsockfd);                                                       //Soy el padre (server) cierro el socket del cliente
            }
        }
        else{                                                                           //Else del chequeo de conexiones máximas
            semaphore_release(&sem_id, &sem);                                           //Devuelvo el semáforo en caso de que haya llegado al límite de conexiones
            sleep(5);                                                                   //Me duermo 5 segundos para volver a chequear si sigo al palo de conexiones activas
        }
    }
    close(sockfd);

    return 0;
}