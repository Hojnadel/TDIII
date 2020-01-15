
MOD_NAME = my_SPI_Driver
obj-m := src/$(MOD_NAME).o
KERNEL_DIR = /home/andres/Documentos/TDIII/R5054_Alpern/KernelBeagle/kernel_beagle

IP=192.168.7.2
PASSWORD = 123

PWD := $(shell pwd)
INCLUDES := $(shell pwd)/inc

all:	compile cpy

		
clean:
	@echo "lalsdlasdlal"
	@echo $(PWD)
	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -C $(KERNEL_DIR) M=$(PWD) clean


compile:
	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -C $(KERNEL_DIR) SUBDIRS=${PWD} -I${INCLUDES} modules

cpy:
	@sshpass -p $(PASSWORD) ssh debian@$(IP) "rm -rf /home/debian/myDriver/$(MOD_NAME).ko"
	@echo Borrando .ko anterior de la BBB
	@sshpass -p $(PASSWORD) scp  src/$(MOD_NAME).ko debian@$(IP):/home/debian/myDriver/
	@echo Copiando .ko nuevo a la BBB
	@echo Listo!