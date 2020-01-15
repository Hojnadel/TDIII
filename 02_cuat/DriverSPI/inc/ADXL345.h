#ifndef __ADXL345_H__
#define __ADXL345_H__

//Addres registers
#define 	DEV_ID		0x00
	#define		DEV_ID_R		"0x8000"

#define		THRESH_TAP	0x1D
#define		OFSX		0x1E
#define		OFSY		0x1f
#define		OFSZ		0x20

#define		BW_RATE		0x2C		//b4 low power; b3:0 output rate
	#define 	BIT_LOW_POWER		(0<<4)		// 0 for normal operation, 1 for reduced power
	#define		BIT_RATE_3200HZ		(0xF<<0)	// 1111 --> 3200HZ
	#define		BIT_RATE_1600HZ		(0xE<<0)	// 1110 --> 1600Hz
	#define		BIT_RATE_800HZ		(0xD<<0)	// 1101 --> 800Hz
	#define		BIT_RATE_400HZ		(0xC<<0)	// 1100 --> 400HZ
	#define		BIT_RATE_200HZ		(0xB<<0)	// 1011 --> 200Hz
	#define		BIT_RATE_100HZ		(0xA<<0)	// 1010 --> 100Hz
	#define		BIT_RATE_50HZ		(0x9<<0)	// 1001 --> 50HZ
	#define		BIT_RATE_25HZ		(0x8<<0)	// 1000 --> 25Hz
	#define		BIT_RATE_12_5HZ		(0x7<<0)	// 0111 --> 12.5Hz
	#define		BIT_RATE_6_25HZ		(0x6<<0)	// 0110 --> 6.25HZ
	#define		BIT_RATE_3_13HZ		(0x5<<0)	// 0101 --> 3.13Hz
	#define		BIT_RATE_1_56HZ		(0x4<<0)	// 0100 --> 1.56Hz
	#define		BIT_RATE_0_78HZ		(0x3<<0)	// 0011 --> 0.78Hz
	#define		BIT_RATE_0_39HZ		(0x2<<0)	// 0010 --> 0.39HZ
	#define		BIT_RATE_0_20HZ		(0x1<<0)	// 0001 --> 0.20Hz
	#define		BIT_RATE_0_10HZ		(0x0<<0)	// 0000 --> 0.10Hz

#define		POWER_CTL	0x2D
	#define 	BIT_MESURE_ON	(1<<3)
	#define		BIT_MESURE_OFF	(0<<3)

#define		DATA_FORMAT	0x31

#define		DATAX0		0x32
	#define		DATAX0_R	"0xB200"

#define		DATAX1		0x33
	#define		DATAX1_R	"0xB300"

#define		DATAY0		0x34
#define		DATAY1		0x35
#define		DATAZ0		0x36
#define		DATAZ1		0x37

#define 	BIT_READ		(1<<15)
#define 	BIT_WRITE		(0<<15)
#define		MB_BIT			(1<<14)
 			

#endif
