

static int my_SPI_probe(struct platform_device * my_SPI_pdev){

	uint32_t reg_aux = 0;
	int status = 0;
	//uint32_t i;						//Para probar el write

	printk(KERN_INFO "... Excecutting probe()... \n");

	//Obtengo la dirección lineal del SPI
	if((my_SPI_OFFSET = of_iomap(my_SPI_pdev->dev.of_node,0)) == NULL){
		printk(KERN_ALERT "... OF_IOMAP for my_SPI has failed ...\n");
		return -1;
	}
	
	printk(KERN_INFO "... The SPI offset address is 0x%p ... \n", my_SPI_OFFSET);




	//Configuro el CM_PER_SPIO_CLKCTRL
	//Mapeo memoria
	if((cm_per_base_map = ioremap(CM_PER_BASE, CM_PER_LEN)) == NULL){
		printk(KERN_ALERT "... IOREMAP of CM_PER_BASE has failed ...\n");

		printk(KERN_INFO "... Releasing my_SPI_OFFSET memory ...\n");
		iounmap(my_SPI_OFFSET);

		return -1;
	}

	printk(KERN_INFO "... The CM_PER linear addres is 0x%p ...\n", cm_per_base_map);	

	// Leo, modifico y escribo el registro del CMPER del SPI		
	reg_aux = ioread32(cm_per_base_map + CM_PER_SPI0_CLKCTRL_OFFSET);
	printk(KERN_INFO "... El registro de CM PER SPI0 vale 0x%08x ...\n", reg_aux);
	reg_aux &= ~CM_PER_SPI0_CLKCTRL_REG_CLEAR;
	reg_aux |= 0x2;
	iowrite32(reg_aux, cm_per_base_map + CM_PER_SPI0_CLKCTRL_OFFSET);
	msleep(10);
	reg_aux = ioread32(cm_per_base_map + CM_PER_SPI0_CLKCTRL_OFFSET);
	printk(KERN_INFO "... El registro de CM PER SPI0 configurado vale 0x%08x ...\n", reg_aux);




	//Configuro el PINMUX
	//Mapeo memoria
	if((pinmux_base_map = ioremap(CONTROL_MODULE_BASE, CONTROL_MODULE_LEN)) == NULL){
		printk(KERN_ALERT "... IOREMAP of CONTROL_MODULE has failed ...\n");

		printk(KERN_INFO "... Releasing CM_PER memory ...\n");
		iounmap(cm_per_base_map);

		printk(KERN_INFO "... Releasing my_SPI_OFFSET memory ...\n");
		iounmap(my_SPI_OFFSET);

		return -1;
	}
	// Configuro el registro de pinmux correspondiente al clock, D0; D1, CS0. Todos tienen la misma configuración:
	// b6 slew rate fast (0
	// b5 Receiver enable (1)
	// b4 Pullup (1)
	// b3 Pullup disable (0)
	// b2:0 PINMUX (000)

	// Configuro el registro de pinmux correspodniente al SCK. P9.22
	reg_aux = ioread32(pinmux_base_map + PINMUX_SPI0_SCLK_OFFSET);
	printk(KERN_INFO "... El registro PINMUX_SCLK vale 0x%08x ...\n", reg_aux);
	reg_aux &= ~PINMUX_REGS_CLEAR;
	reg_aux |= PIN_MUX_CFG;
	iowrite32(reg_aux, pinmux_base_map + PINMUX_SPI0_SCLK_OFFSET);
	reg_aux = ioread32(pinmux_base_map + PINMUX_SPI0_SCLK_OFFSET);
	printk(KERN_INFO "... El registro PINMUX_SCLK configurado vale 0x%08x ...\n", reg_aux);

	// Configuro el registro de pinmux correspodniente al DO. P9.21
	reg_aux = ioread32(pinmux_base_map + PINMUX_SPI0_D0_OFFSET);
	reg_aux &= ~PINMUX_REGS_CLEAR;
	reg_aux |= PIN_MUX_CFG;	 
	iowrite32(reg_aux, pinmux_base_map + PINMUX_SPI0_D0_OFFSET);

	// Configuro el registro de pinmux correspodniente al D1. P9.18
	reg_aux = ioread32(pinmux_base_map + PINMUX_SPI0_D1_OFFSET);
	reg_aux &= ~PINMUX_REGS_CLEAR;
	reg_aux |= PIN_MUX_CFG;	 
	iowrite32(reg_aux, pinmux_base_map + PINMUX_SPI0_D1_OFFSET);

	// Configuro el registro de pinmux correspodniente al CS0. P9.17
	reg_aux = ioread32(pinmux_base_map + PINMUX_SPI0_CS0_OFFSET);
	reg_aux &= ~PINMUX_REGS_CLEAR;
	reg_aux |= PIN_MUX_CFG;	 
	iowrite32(reg_aux, pinmux_base_map + PINMUX_SPI0_CS0_OFFSET);



	// Mapeo la dirección física en lineal de los registros de SPI. 
	// Deben configurarse MCSPI_SYSCONFIG, MCSPI_MODULCTRL, MCSPI_CH0CONF, MCSPI_CH0CTRL
	if((spi0_base_map = ioremap(MCSPI0_BASE_ADDRESS, MCSPI0_LEN)) == NULL){
		printk(KERN_ALERT "... IOREMAP of MCSPI0_BASE_ADDRESS has failed ...\n");

		iounmap(pinmux_base_map);
		printk(KERN_INFO "... Releasing PIN_MUX memory ...\n");

		iounmap(cm_per_base_map);
		printk(KERN_INFO "... Releasing CM_PER memory ...\n");

		iounmap(my_SPI_OFFSET);
		printk(KERN_INFO "... Releasing my_SPI_OFFSET memory ...\n");

		printk(KERN_INFO "\n");

		return -1;
	}

	// Configuración del registro MCSPI_SYSCONFIG
	reg_aux = ioread32(spi0_base_map + MCSPI_SYSCONFIG_OFFSET);
	printk(KERN_INFO "... El registro MCSPI_SYSCONFIG vale 0x%08x ...\n", reg_aux);

	printk(KERN_INFO "... Haciendo el SOFTRESET ...\n");
	reg_aux |= SOFTRESET;
	iowrite32(reg_aux, spi0_base_map + MCSPI_SYSCONFIG_OFFSET);
	msleep(20);

	printk(KERN_INFO "... El registro MCSPI_SYSCONFIG vale 0x%08x ...\n", reg_aux);
	reg_aux &= ~MCSPI0_SYSCONFIG_REGS_CLEAR;
	reg_aux |= (CLOCKACTIVITY | SIDLEMODE | SOFTRESET | AUTOIDLE);
	iowrite32(reg_aux, spi0_base_map + MCSPI_SYSCONFIG_OFFSET);
	reg_aux = ioread32(spi0_base_map + MCSPI_SYSCONFIG_OFFSET);
	printk(KERN_INFO "... El registro MCSPI_SYSCONFIG configurado vale 0x%08x ...\n", reg_aux);

	// Configuración del registro MCSPI_MODULCTRL
	reg_aux = ioread32(spi0_base_map + MCSPI_MODULCTRL_OFFSET);
	printk(KERN_INFO "... El registro MCSPI_MODULCTRL vale 0x%08x ...\n", reg_aux);
	reg_aux &= ~MCSPI0_MODULCTRL_REGS_CLEAR;
	reg_aux |= (FDAA | MOA | INITDLY | SYSTEM_TEST | MS | PIN34 | SINGLE);
	iowrite32(reg_aux, spi0_base_map + MCSPI_MODULCTRL_OFFSET);
	reg_aux = ioread32(spi0_base_map + MCSPI_MODULCTRL_OFFSET);
	printk(KERN_INFO "... El registro MCSPI_MODULCTRL configurado vale 0x%08x ...\n", reg_aux);

	// Configuración del registro MCSPI_SYST
	/*reg_aux = ioread32(spi0_base_map + MCSPI_SYST_OFFEST);
	printk(KERN_INFO "... El registro MCSPI_MODULCTRL vale 0x%08x ...\n", reg_aux);
	reg_aux  = SPIENDIR | SPIEN_0;
	iowrite32(reg_aux, spi0_base_map + MCSPI_SYST_OFFEST);
	reg_aux = ioread32(spi0_base_map + MCSPI_SYST_OFFEST);
	printk(KERN_INFO "... El registro MCSPI_SYST configurado vale 0x%08x ...\n", reg_aux);	*/

	// Configuración del registro MCSPI_CH0CONF
	reg_aux = ioread32(spi0_base_map + MCSPI_CH0CONF_OFFSET);
	printk(KERN_INFO "... El registro MCSPI_CH0CONF vale 0x%08x ...\n", reg_aux);
	reg_aux &= ~MCSPI0_CH0CONF_REGS_CLEAR;
	reg_aux |= (SBPOL | SBE | FORCE | WL | EPOL | CLKD | POL | PHA);
	iowrite32(reg_aux, spi0_base_map + MCSPI_CH0CONF_OFFSET);
	reg_aux = ioread32(spi0_base_map + MCSPI_CH0CONF_OFFSET);
	printk(KERN_INFO "... El registro MCSPI_CH0CONF configurado vale 0x%08x ...\n", reg_aux);

	
	// Configuración del registro MCSPI_CH0CTRL
	reg_aux = ioread32(spi0_base_map + MCSPI_CH0CTRL_OFFSET);
	printk(KERN_INFO "... El registro MCSPI_CH0CTRL vale 0x%08x ...\n", reg_aux);
	reg_aux &= ~MCSPI0_CH0CTRL_REGS_CLEAR;
	reg_aux |= EN;
	iowrite32(reg_aux, spi0_base_map + MCSPI_CH0CTRL_OFFSET);
	reg_aux = ioread32(spi0_base_map + MCSPI_CH0CTRL_OFFSET);
	printk(KERN_INFO "... El registro MCSPI_CH0CTRL configurado vale 0x%08x ...\n", reg_aux);	

	//****Prueba de clock y Tx***
	/*for(i=0; i<10000; i++){
		iowrite32(0x35, spi0_base_map + MCSPI_TX0);
		reg_aux = ioread32(spi0_base_map + MCSPI_RX0);
	}*/

	printk(KERN_INFO "... El registro MCSPI_IRQ_ENABLE configurado vale 0x%08x ...\n", reg_aux);

	if((spi_virq =  platform_get_irq(my_SPI_pdev, 0)) == 0){
		printk(KERN_ALERT "... No se puedo obtener una VIRQ ...\n");
		iounmap(spi0_base_map);
		printk(KERN_INFO "... Releasing SPI0_BASE_MAP memory ...\n");

		iounmap(pinmux_base_map);
		printk(KERN_INFO "... Releasing PIN_MUX memory ...\n");

		iounmap(cm_per_base_map);
		printk(KERN_INFO "... Releasing CM_PER memory ...\n");

		iounmap(my_SPI_OFFSET);
		printk(KERN_INFO "... Releasing my_SPI_OFFSET memory ...\n");
		
		return spi_virq;
	}
	printk(KERN_INFO "El VIRQ otorgado es %i", spi_virq);

	if((status = request_irq(spi_virq, (irq_handler_t) my_spi_handler, IRQF_TRIGGER_RISING, my_SPI_pdev->name, NULL))!=0){
		printk(KERN_ALERT "... Error at request_irq() ...\nrequest_irq return value: %i",status);
		
		iounmap(spi0_base_map);
		printk(KERN_INFO "... Releasing SPI0_BASE_MAP memory ...\n");

		iounmap(pinmux_base_map);
		printk(KERN_INFO "... Releasing PIN_MUX memory ...\n");

		iounmap(cm_per_base_map);
		printk(KERN_INFO "... Releasing CM_PER memory ...\n");

		iounmap(my_SPI_OFFSET);
		printk(KERN_INFO "... Releasing my_SPI_OFFSET memory ...\n");
		return status;
	}

	//msleep(1);

	// Habilitación de las interrupciones
	reg_aux = ioread32(spi0_base_map + MCSPI_IRQ_ENABLE);
	reg_aux = (1<<2) | (1<<0);
	iowrite32(reg_aux, spi0_base_map + MCSPI_IRQ_ENABLE);
	iowrite32(((1<<2) | 1), spi0_base_map + MCSPI_IRQ_STATUS);

	print_status_registers(spi0_base_map);

	printk(KERN_INFO "... Finishing probe() ...\n");
	return 0;
}




static int my_SPI_remove(struct platform_device * my_SPI_pdev){

	printk(KERN_INFO "... Excecutting remove()... \n");

	printk(KERN_INFO "... Releasing my_spi_handler ...\n");
	free_irq(spi_virq, 0);
	
	iounmap(spi0_base_map);
	printk(KERN_INFO "... Releasing SPI0_BASE_MAP memory ...\n");

	iounmap(pinmux_base_map);
	printk(KERN_INFO "... Releasing PIN_MUX memory ...\n");

	iounmap(cm_per_base_map);
	printk(KERN_INFO "... Releasing CM_PER memory ...\n");

	iounmap(my_SPI_OFFSET);
	printk(KERN_INFO "... Releasing my_SPI_OFFSET memory ...\n");

	printk(KERN_INFO "\n");

	return 0;
}


