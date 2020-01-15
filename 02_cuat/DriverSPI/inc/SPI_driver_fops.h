// Header SPI_driver_fops.h

#ifndef __SPI_DRIVER_FOPS_H__
#define __SPI_DRIVER_FOPS_H__

#define		SUCCESS			0
#define 	TX_BUFFER_LEN	2
#define 	RX_BUFFER_LEN	7

/*****File Operations PRIMITIVES*****/
static int my_SPI_open(struct inode *, struct file *);
static int my_SPI_release(struct inode *, struct file *);
static ssize_t my_SPI_write(struct file *, const char __user *, size_t, loff_t *);
static ssize_t my_SPI_read(struct file *, char __user *, size_t, loff_t *);

#endif