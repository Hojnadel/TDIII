/*****GLOBAL ENTITIES*****/
static dev_t my_SPI_dev;						
static struct cdev* ptr_cdev;
static struct class* ptr_class_my_SPI;
static struct device* ptr_device_my_SPI;

static struct of_device_id my_SPI_dt_ids[] = 
   {
      {.compatible = "td3_spi" },
      {},
   };


static struct platform_driver my_SPI_platform_driver = {
	.probe = my_SPI_probe,
	.remove = my_SPI_remove,
	.driver = {
		.name = "td3_spi",
		.of_match_table = my_SPI_dt_ids,
	},
};

static struct file_operations my_SPI_fops = {
	.owner = THIS_MODULE,
	.read = my_SPI_read,
	.write = my_SPI_write,
	.open = my_SPI_open,
	.release = my_SPI_release,
};


static volatile void __iomem * my_SPI_OFFSET;
static volatile void * cm_per_base_map;
static volatile void * pinmux_base_map;
static volatile void * spi0_base_map;
static volatile int spi_virq = 0;


DEFINE_SEMAPHORE(sem);