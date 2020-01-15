typedef unsigned int uint32_t;


/*** Variables asociadas al archivo de cofniguración ***/
uint32_t backlog = DEFAULT_BACKLOG;
uint32_t max_conn = DEFAULT_MAX_CONN;
uint32_t output_rate = DEFAULT_OUTPUT_RATE;
uint32_t max_vector = DEFAULT_MEAN_VECTOR;

uint8_t chng_cnfg_flag = OFF;
uint8_t flag_sigterm = OFF;

uint32_t vector_index = 0;	//La usa el adiquisidor y el promediador 

float avg_x, avg_y, avg_z;  //Las usa el promediador y el servidor
float * x_vector, *y_vector, *z_vector; //Las usa el adquisidor y el promediador


/*** MUTEX ***/
pthread_mutex_t mutex;


union semun {
    int              val;    /* Value for SETVAL */
    struct semid_ds *buf;    /* Buffer for IPC_STAT, IPC_SET */
    unsigned short  *array;  /* Array for GETALL, SETALL */
    struct seminfo  *__buf;  /* Buffer for IPC_INFO (Linux specific) */
};

struct shrmem_conn_counter_struct{
      int conn_counter;
};

struct clear_resources_struct{
	void*	_sharedmem;
	int*	_shmid;
	int* 	_semid;
	union semun* 	_semun;
	struct sembuf* _sem;
	int 	_sockfd;
	pthread_t _acqid;
	pthread_t _avgid;
	pthread_t _configid;
};

