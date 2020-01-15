#include <linux/init.h>
#include <linux/kern_levels.h>
#include <linux/err.h>
#include <linux/uaccess.h>
#include <linux/slab.h>
#include <linux/ctype.h>
#include <linux/module.h>
#include <linux/fs.h> 			// Acá están los prototipos de alloc_chrdev_region y unregister_chrdev_region
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/mod_devicetable.h>
#include <linux/platform_device.h>
#include <linux/of_address.h>
#include <linux/io.h>
#include <linux/delay.h>
#include <linux/kernel.h>
#include <linux/interrupt.h>
#include <asm/uaccess.h>
#include <asm/errno.h>
#include <linux/semaphore.h>

#include "../inc/SPI_driver_probe.h"
#include "../inc/SPI_driver_fops.h"
#include "../inc/SPI_driver_func.h"
#include "../inc/ADXL345.h"

#include "SPI_driver_globals.c"
#include "SPI_driver_func.c"
#include "SPI_driver_handler.c"
#include "SPI_driver_probe.c"
#include "SPI_driver_fops.c"
#include "SPI_driver_init.c"


