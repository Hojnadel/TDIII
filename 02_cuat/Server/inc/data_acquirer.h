#ifndef __DATA_ACQUIRER_H__
#define __DATA_ACQUIRER_H__


#define BUFFER_TX_LEN		2
#define	BUFFER_RX_LEN		1

#define SPI_PATH		"/dev/my_SPI_Driver"
#define X_AXIS_OFFSET	7.5
#define Y_AXIS_OFFSET	-4.5
#define Z_AXIS_OFFSET	231.0

#define X_AXIS_GAIN		0.349514563
#define Y_AXIS_GAIN		0.341555977
#define Z_AXIS_GAIN		0.355029586

#define	READ_DELAY		350		//mayor a Tclk * 16 = 1/50kHz * 16 = 320us

#define	INITIAL_OUTPUT_RATE 	125000

#endif