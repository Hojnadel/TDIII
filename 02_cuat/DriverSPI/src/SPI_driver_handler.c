

static irqreturn_t my_spi_handler(int spi_virq, void *dev_id, struct pt_regs *regs ){
	int status = 0;
	//uint8_t RX_data = 0x0;

	//printk(KERN_ALERT "... Excecutting my_spi_handler ...\n");
	status = ioread32(spi0_base_map + MCSPI_IRQ_STATUS);
	if( (status>>RX0_FULL) & 1){
		//printk(KERN_INFO "... Interrumpio RX FULL ...\n");
		//RX_data = ioread32(spi0_base_map + MCSPI_RX0);
		//printk(KERN_INFO "... Dato leido en la interrupcion: 0x%02X ...\n", RX_data);
		up(&sem);
		//printk(KERN_INFO "Semaforo liberado\n");
	}
	if( (status>>TX0_EMPTY) &1){
	// 	printk(KERN_INFO "... Interrumpio por TX EMPTY ... \n");
	}
	iowrite32(((1<<RX0_FULL) | (1<<TX0_EMPTY)), spi0_base_map + MCSPI_IRQ_STATUS);
	return IRQ_HANDLED;
}