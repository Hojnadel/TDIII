

static int device_open = 0;

static int my_SPI_open(struct inode * my_SPI_inode, struct file * ptr_file_my_SPI){

	if (device_open){
		printk(KERN_ALERT "... Device alredy open ...\n");
		return -EBUSY;
	} 

   device_open++;
	printk(KERN_INFO "... Device open ...\n");

   return SUCCESS;
}

static int my_SPI_release(struct inode * my_SPI_inode, struct file * ptr_file_my_SPI){
	device_open--;
   printk(KERN_INFO "... Device closed ...\n\n");
	return 0;
}



static ssize_t my_SPI_write(struct file * ptr_file_my_SPI, const char __user * my_SPI_user_buffer, size_t size, loff_t * ptr_offset){

	uint8_t RX_data = 0;
   uint32_t status = 0;

   printk(KERN_INFO "... Configurating ADXL345 ...\n");


   /*** Leo y muestro por consola de kernel el nombre del dispositivo ***/
   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   cs0_action(spi0_base_map, CS_LINE_DOWN);
   iowrite32((DEV_ID<<8)|BIT_READ, spi0_base_map + MCSPI_TX0);   //Habilito la medicion
   cs0_action(spi0_base_map, CS_LINE_UP);
   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   RX_data = ioread32(spi0_base_map + MCSPI_RX0);
   up(&sem);
   printk(KERN_INFO "El dispositivo se identifico como: %X\n", RX_data);


   /*** Configuro el output rate del sensor ***/
   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   cs0_action(spi0_base_map, CS_LINE_DOWN);
	iowrite32((BW_RATE<<8) | BIT_WRITE | BIT_RATE_6_25HZ, spi0_base_map + MCSPI_TX0); //Configuro el data output rate
   cs0_action(spi0_base_map, CS_LINE_UP);


   /*** Comienzo a medir ***/
   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   cs0_action(spi0_base_map, CS_LINE_DOWN);
   iowrite32((POWER_CTL<<8) | BIT_WRITE | BIT_MESURE_ON, spi0_base_map + MCSPI_TX0);   //Habilito la medicion
   cs0_action(spi0_base_map, CS_LINE_UP);

   return size;
}




static ssize_t my_SPI_read(struct file * ptr_file_my_SPI, char __user * my_SPI_user_buffer, size_t size, loff_t * ptr_offset){

   int8_t RX_data = 0xFF;
   char buffer[RX_BUFFER_LEN]={0};
   uint32_t status;

   printk(KERN_INFO "... Reading ...\n");

   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   cs0_action(spi0_base_map, CS_LINE_DOWN);
   iowrite32((DATAX0<<8) | BIT_READ, spi0_base_map + MCSPI_TX0); //Configuro el data output rate
   cs0_action(spi0_base_map, CS_LINE_UP);
   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   RX_data = ioread32(spi0_base_map + MCSPI_RX0);
   up(&sem);
   buffer[0] = RX_data;

   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   cs0_action(spi0_base_map, CS_LINE_DOWN);
   iowrite32((DATAX1<<8) | BIT_READ, spi0_base_map + MCSPI_TX0); //Configuro el data output rate
   cs0_action(spi0_base_map, CS_LINE_UP);
   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   RX_data = ioread32(spi0_base_map + MCSPI_RX0);
   up(&sem);
   buffer[1] = RX_data;

   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   cs0_action(spi0_base_map, CS_LINE_DOWN);
   iowrite32((DATAY0<<8) | BIT_READ, spi0_base_map + MCSPI_TX0); //Configuro el data output rate
   cs0_action(spi0_base_map, CS_LINE_UP);
   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   RX_data = ioread32(spi0_base_map + MCSPI_RX0);
   up(&sem);
   buffer[2] = RX_data;

   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   cs0_action(spi0_base_map, CS_LINE_DOWN);
   iowrite32((DATAY1<<8) | BIT_READ, spi0_base_map + MCSPI_TX0); //Configuro el data output rate
   cs0_action(spi0_base_map, CS_LINE_UP);
   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   RX_data = ioread32(spi0_base_map + MCSPI_RX0);
   up(&sem);
   buffer[3] = RX_data;

   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   cs0_action(spi0_base_map, CS_LINE_DOWN);
   iowrite32((DATAZ0<<8) | BIT_READ, spi0_base_map + MCSPI_TX0); //Configuro el data output rate
   cs0_action(spi0_base_map, CS_LINE_UP);
   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   RX_data = ioread32(spi0_base_map + MCSPI_RX0);
   up(&sem);
   buffer[4] = RX_data;

   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   cs0_action(spi0_base_map, CS_LINE_DOWN);
   iowrite32((DATAZ1<<8) | BIT_READ, spi0_base_map + MCSPI_TX0); //Configuro el data output rate
   cs0_action(spi0_base_map, CS_LINE_UP);
   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   RX_data = ioread32(spi0_base_map + MCSPI_RX0);
   up(&sem);
   buffer[5] = RX_data;

   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   cs0_action(spi0_base_map, CS_LINE_DOWN);
   iowrite32((DEV_ID<<8)|BIT_READ, spi0_base_map + MCSPI_TX0);   //Habilito la medicion
   cs0_action(spi0_base_map, CS_LINE_UP);
   if((status=down_interruptible(&sem))!=0){
      printk(KERN_ALERT "No se pudo tomar el semaforo de escritura. No se realizará la operación\n");
      return status;
   }
   RX_data = ioread32(spi0_base_map + MCSPI_RX0);
   up(&sem);
   buffer[6] = RX_data;

   if((status = copy_to_user( (void*) my_SPI_user_buffer, (void*) buffer, sizeof(buffer))) !=0){
      printk(KERN_ALERT "... ERROR al escribir en el user_buffer ...\n");
      return status;
   }

   return size;

}

