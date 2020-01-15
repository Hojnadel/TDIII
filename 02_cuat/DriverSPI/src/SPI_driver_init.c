#define FIRST_MINOR 0
#define MINOR_QTY 	1
#define MAX_LEN 	512
#define DEVICE_NAME	"my_SPI_Driver"
#define CLASS_NAME 	"my_SPI_Class"


MODULE_LICENSE("Dual BSD/GPL");
 
MODULE_DEVICE_TABLE(of, my_SPI_dt_ids);


/*FUNCTIONS*/
static int my_SPI_driver_init(void){

	int status_err = 0;

	printk(KERN_INFO "\n");
	printk(KERN_INFO "... ATTACHING my_SPI_driver ... \n");


	/*Rerservo una cantidad MINOR_QTY de dispositivos llamados DEVICE_NAME y empezando a enumerarlos desde FIRST_MINOR. Se le pasa
	también la dirección de memoria de un dev_t vacío que al registrarse se completa con el dispositivo registrado. El número mayor se 
	asigna automáticamente por el SO. Devuelve 0 en success y un número negativo en error.*/
	if((status_err = alloc_chrdev_region(&my_SPI_dev, FIRST_MINOR, MINOR_QTY, DEVICE_NAME ))<0){
		printk(KERN_ALERT "... ERROR in alloc_chrdev_region ... \n");
		return status_err;
	}

	printk( KERN_INFO "... mayor and minor number assigned ... \n");


	/*This is used to create a struct class pointer that can then be used in calls to class_device_create.*/
	if((ptr_class_my_SPI = class_create(THIS_MODULE, CLASS_NAME)) == NULL){
		printk(KERN_ALERT "... error creating class ...\n");

		cdev_del(ptr_cdev);
		printk(KERN_INFO "... device unregistered ...\n");

		unregister_chrdev_region(my_SPI_dev, MINOR_QTY);
		printk(KERN_INFO "... mayor and minor numbers deassigned ... \n");

		return -1;
	}

	printk(KERN_INFO "... Class created ...\n");

	/*Creo el char device en /dev/*/
	if((ptr_device_my_SPI = device_create(ptr_class_my_SPI, NULL, my_SPI_dev, NULL, DEVICE_NAME)) == NULL){
		printk(KERN_ALERT "... error at creating the device in the SPI class ... \n");

		class_destroy(ptr_class_my_SPI);
		printk(KERN_INFO "... SPI class detroyed ...\n");

		cdev_del(ptr_cdev);
		printk(KERN_INFO "... device unregistered ...\n");

		unregister_chrdev_region(my_SPI_dev, MINOR_QTY);
		printk(KERN_INFO "... mayor and minor numbers deassigned ... \n");

		return -1;
	}

	printk(KERN_INFO "... my_SPI_device created ... \n");


	/*Inicializo una estructura cdev. La función devuelve la estructura inicializada a través del puntero. Representa el char device*/
	if((ptr_cdev = cdev_alloc()) == NULL){
		printk(KERN_ALERT "... ERROR in cdev_alloc ...");
		
		unregister_chrdev_region(my_SPI_dev, MINOR_QTY);
		printk(KERN_INFO "... mayor and minor numbers deassigned ... \n");

		return -1;
	}

	printk( KERN_INFO "... cdev struct initialized ... \n");


	/*Asocio en runtime la estructura cdev con el puntero correspondiente a los file operations y lo asocio al dispositivo registrado*/
	ptr_cdev->owner = THIS_MODULE;
	ptr_cdev->ops = &my_SPI_fops;
	ptr_cdev->dev = my_SPI_dev;


	printk( KERN_INFO "... file operations y dispositivo asociado al char device ... \n");


	/*Registración del dispositivo. Devuelve un número menor a 0 en caso de error, 0 en success*/
	/*cdev_add registers a character device with the kernel. The kernel maintains a list of character devices under cdev_map*/
	/*cdev_add adds the device represented by p to the system, making it live immediately.*/
	if((status_err = cdev_add(ptr_cdev, my_SPI_dev, MINOR_QTY)) < 0){				// segundo parametro era FIRST_MINOR
		printk( KERN_ALERT "... error at device registration (cdev_add) ... \n");

		unregister_chrdev_region(my_SPI_dev, MINOR_QTY);
		printk(KERN_INFO "... mayor and minor numbers deassigned ... \n");

		return status_err;
	}

	printk(KERN_INFO "... Device registered (cdev_add)... \n");



	printk(KERN_INFO "... my_SPI_driver correctly ATTACHED... \n");	
	printk(KERN_INFO "\n");

	if((status_err = platform_driver_register(&my_SPI_platform_driver)) <0){
		printk(KERN_ALERT "... error al platform driver registration ...\n");

		device_destroy(ptr_class_my_SPI, my_SPI_dev);
		printk(KERN_INFO "... my_SPI_device destroyed ... \n");

		class_destroy(ptr_class_my_SPI);
		printk(KERN_INFO "... SPI class detroyed ...\n");

		cdev_del(ptr_cdev);
		printk(KERN_INFO "... device unregistered ...\n");

		unregister_chrdev_region(my_SPI_dev, MINOR_QTY);
		printk(KERN_INFO "... mayor and minor numbers deassigned ... \n");

		printk(KERN_INFO "... DEATTACHED my_SPI_driver ... \n");
		printk(KERN_INFO "\n");

		return status_err;
	}

	printk(KERN_INFO "... my_SPI_platform_driver correclty registered ... \n");
	printk("\n");

	return status_err;
}

static void my_SPI_driver_exit(void){

	printk(KERN_INFO "... unregistering my_SPI_platform_driver ...\n");
	platform_driver_unregister(&my_SPI_platform_driver);

	printk(KERN_INFO "... DEATTACHING my_SPI_driver ... \n");

	device_destroy(ptr_class_my_SPI, my_SPI_dev);
	printk(KERN_INFO "... my_SPI_device destroyed ... \n");

	class_destroy(ptr_class_my_SPI);
	printk(KERN_INFO "... SPI class detroyed ...\n");

	cdev_del(ptr_cdev);
	printk(KERN_INFO "... device unregistered ...\n");

	unregister_chrdev_region(my_SPI_dev, MINOR_QTY);
	printk(KERN_INFO "... mayor and minor numbers deassigned ... \n");

	printk(KERN_INFO "... DEATTACHED my_SPI_driver ... \n");
	printk(KERN_INFO "\n");

}


module_init(my_SPI_driver_init);
module_exit(my_SPI_driver_exit);

