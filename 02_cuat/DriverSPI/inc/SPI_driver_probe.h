// Header SPI_dirver_probe.h

#ifndef __SPI_DRIVER_PROBE_H__
#define __SPI_DRIVER_PROBE_H__


// CM_PER DEFINES
#define CM_PER_BASE 					0x44E00000
#define CM_PER_LEN 						0x400
#define CM_PER_SPI0_CLKCTRL_OFFSET		0x4C
#define CM_PER_RESET_VALUE				0x0003000
#define CM_PER_SPI0_CLKCTRL_REG_CLEAR	(0x3)


// CONTROL MODULE DEFINES
#define CONTROL_MODULE_BASE 			0x44E10000
#define CONTROL_MODULE_LEN 				0x1000
#define PINMUX_SPI0_SCLK_OFFSET			0x950
#define PINMUX_SPI0_D0_OFFSET			0x954
#define PINMUX_SPI0_D1_OFFSET 			0x958
#define PINMUX_SPI0_CS0_OFFSET 			0x95C
#define CONTROL_MODULE_RESET_VALUE 		0x0000027
#define PINMUX_REGS_CLEAR				(0x7F)
#define	PIN_MUX_CFG						(0x30) 			//Slew rate FAST 0, Receiver enable 1, PULL UP 1, ENABLE 0, MODE 000;


// SPI CONFIGURATION REGISTERS DEFINES
#define MCSPI0_BASE_ADDRESS 		0x48030000
#define MCSPI0_LEN					0x1000

// MCSPI0_SYSCONFIG REGISTERS
#define MCSPI_SYSCONFIG_OFFSET 			0x110
#define MCSPI0_SYSCONFIG_RESET_VALUE 	0x0000311
#define MCSPI0_SYSCONFIG_REGS_CLEAR 	((0x3<<8) | (0x3<<3) | (0x1<<1) | (0x1))
#define CLOCKACTIVITY 					(0x3<<8)
#define SIDLEMODE 						(0x1<<3)
#define SOFTRESET 						(0x0<<1)
#define AUTOIDLE 						(0x0<<0)

// MCSPI_SYST
#define MCSPI_SYST_OFFEST				0x124
#define SPIENDIR 						(0<<10)
#define SPIEN_0							(0<<0)


// MCSPI0_MODULCTRL REGISTERS
#define MCSPI_MODULCTRL_OFFSET			0x128
#define MCSPI0_MODULCTRL_RESET_VALUE	0x0000004
#define	MCSPI0_MODULCTRL_REGS_CLEAR		(0x1F)
#define FDAA							(0x0<<8)
#define MOA 							(0x0<<7)
#define INITDLY 						(0x0<<4)
#define SYSTEM_TEST 					(0x0<<3)
#define MS 								(0x0<<2)
#define PIN34							(0x0<<1)
#define SINGLE							(0x1<<0)

// MCSPI0_ CH0CONF DEFINES
#define MCSPI_CH0CONF_OFFSET			0x12C
#define MCSPI0_CH0CONF_RESET_VALUE		0x00060000
#define MCSPI0_CH0CONF_REGS_CLEAR 	((3<<25) | (1<<24) | (1<<23) | (1<<20) | (0xF<<7) | (0x1<<6) | (0xF<<2) | (0x1<<1) | (0x1<<0))
#define TCS 						(0x1<<25) 				//Chip select time
#define SBPOL 						(0x1<<24)
#define SBE 						(0x0<<23)
#define FORCE						(0x1<<20)
#define WL							(0xF<<7)				//Word Length: 0xF=16b	0x7=8b
#define EPOL 						(0x1<<6)
#define CLKD 						(0xA<<2)				//Divido por 1024 => CLK = 46.7kHz
#define POL 						(0x1<<1)
#define PHA 						(0x1<<0)


// MCSPI0_CH0CTRL _DEFINES
#define MCSPI_CH0CTRL_OFFSET		0x134
#define MCSPI0_CH0CTRL_RESET_VALUE	0x0000000
#define MCSPI0_CH0CTRL_REGS_CLEAR	(0x1<<0)
#define EN 							(0x1<<0)

#define MCSPI_IRQ_ENABLE 			0x11C
#define MCSPI_IRQ_STATUS			0x118
#define MCSPI_CH0STAT				0x130

#define RX0_FULL 					0x2
#define TX0_EMPTY 					0x0


#define MCSPI_TX0 					0x138
#define MCSPI_RX0 					0x13C


// probe() and remove() primitives
static int my_SPI_probe(struct platform_device * );
static int my_SPI_remove(struct platform_device * );

static irqreturn_t my_spi_handler(int spi_virq, void *dev_id, struct pt_regs *regs );

#endif