# Makefile para TD3 UTN FRBA
# Version: 12.0
# Año: 2018
#
# NOTA: Los paths relativos deben especificarse SIN el "./"
#		Los archivos assembler deben tener extension .asm 
#
# Installar GCC 7 para __attribute__((interrupt)):
# sudo add-apt-repository ppa:jonathonf/gcc-7.1
# sudo apt-get update
# sudo apt-get install gcc-7 g++-7










# ******************************************************************** #
# ************* Definiciones modificables por el usuario ************* #
# ******************************************************************** #

# Path donde el BOCHS irá a buscar el binario (así, una vez generado, copia el binario a ese path y se puede ejecutar el bochs directamente sin modificar nada)
#PATH_BIOS = 

# Carpeta donde se encuentran los archivos fuente (.asm)
CARPETA_SRC = src

# Carpeta donde se encuentran los archivos cabecera (.h)
CARPETA_INC = inc

# Carpeta donde se desea generar el archivo binario (.bin)
CARPETA_BIN = bin

# Carpeta donde se desea generar el archivo de Formato Ejecutable y Linkeable (.elf)
CARPETA_ELF = bin

# Carpeta donde se desea generar el archivo de lista del binario (.lst)
CARPETA_LST = log

# Carpeta donde se desean generar los archivos objeto (.o)
CARPETA_OBJ = bin

# Carpeta donde se desean generar los archivos de texto para control (.txt)
CARPETA_TXT = log

# Carpeta donde se desean guardar los archivos de texto suplementarios (.txt)
CARPETA_SUP = sup

# Carpeta donde se desean guardar el mapa de memoria (.map)
CARPETA_MAP = log

# Carpeta donde se encuentra el linker script (.ld)
CARPETA_LDS = sup

# Carpeta donde se encuentra el linker script (.ld)
LDS_NAME = linker_script

# Nombre y extension del archivo de configuracion del bochs
BOCHSRC = bochs.cfg

# Nombre del archivo binario generado
OUTPUT_NAME = bios

# Lista de directorios
DIRECTORIOS = src/ inc/ lib/ bin/ doc/ log/ sup/

# Flags del compilador de assembler
# "-felf32": Formato de salida elf 32 bits
ASMFLAGS = -I$(CARPETA_INC)/ -Wall -Wno-gnu-elf-extensions -felf32

# Flags del compilador
CFLAGS = -I$(CARPETA_INC)/ -c -m32 -fno-PIC -fno-stack-protector -fno-asynchronous-unwind-tables -O0 -Wall
CFLAGS16 = -I$(CARPETA_INC)/ -c -m16 -fno-PIC -fno-stack-protector -fno-asynchronous-unwind-tables -O0 -Wall
# -fpic: "Generate position-independent code (PIC)
# 			suitable for use in a shared library, if supported for the target machine.
# 			Such code accesses all constant addresses through a global offset table (GOT)."
#
# -fstack-protector: "Emit extra code to check for buffer overflows, such as stack smashing attacks.
# 					This is done by adding a guard variable to functions with vulnerable objects.
# 					This includes functions that call alloca, and functions with buffers larger than 8 bytes.
# 					The guards are initialized when a function is entered and then checked when the function exits.
# 					If a guard check fails, an error message is printed and the program exits."
#
# -fstack-protector-all: "Like -fstack-protector except that all functions are protected."
#
# -fasynchronous-unwind-tables: "Enable exception handling. Generates extra code needed to propagate
# 					exceptions. For some targets, this implies GCC generates frame unwind
# 					information for all functions, which can produce significant data
# 					size overhead, although it does not affect execution."


# Flags del linker
# "-z max-page-size=0x01000": Tamaño maximo de pagina 
# "-m elf_i386": Emula un procesador i386
LFLAGS = -z max-page-size=0x01000 -m elf_i386 -T $(CARPETA_LDS)/$(LDS_NAME).ld -e _init16 -Map $(CARPETA_MAP)/$(OUTPUT_NAME).map

# Flags del objdump
# "-C": Decodifica los nombres de símbolo
# "-p": Display object format specific file header contents
# "-r": Display the relocation entries in the file
# "-s": Muestra el contenido completo de todas las secciones pedidas
# "-S": Muestra código fuente junto con código desensamblado 
# "-x": Muestra contenido de todos los headers
# "--prefix-addresses": Muestra las direcciones completas a lo largo del desensamblado
ODFLAGS	= -C -p -r -s -S -x --prefix-addresses










# ******************************************************************** #
# ************* NO modificar las siguientes definiciones ************* #
# ******************************************************************** #

# Compilador de assembler
ASMC = nasm

# Compilador de C
CC = gcc

# Linker
LINKER = ld

# Path y nombre del binario (.bin)
OUTPUT_BIN = $(CARPETA_BIN)/$(OUTPUT_NAME).bin

# Path y nombre del archivo de salida en formato linkeable y ejecutable (.elf)
OUTPUT_ELF = $(CARPETA_ELF)/$(OUTPUT_NAME).elf

# Path y nombre de los archivos fuente (.asm)
SRCS = $(wildcard $(CARPETA_SRC)/*.asm) $(wildcard $(CARPETA_SRC)/*.c) $(wildcard $(CARPETA_SRC)/*/*.asm) $(wildcard $(CARPETA_SRC)/*/*.c)

# Path y nombre de los archivos elf (.elf)
ELFS = $(subst .c,.c.elf,$(subst $(CARPETA_SRC)/,$(CARPETA_OBJ)/,$(SRCS:.asm=.elf)))

# Path y nombre del binario generado
BIOS = $(PATH_BIOS)/$(OUTPUT_NAME).bin

# Lista de carpetas para crear si no existen
DIRECTORY = $(sort $(DIRECTORIOS) $(dir $(ELFS)) $(dir $(subst $(CARPETA_OBJ)/,$(CARPETA_LST)/,$(ELFS))))

# Define una funcion para crear la estructura de carpetas
define CREAR_ESTRUCTURA
	@echo	''
	@echo	'-----> Creando estructura de carpetas'

	mkdir -p $(DIRECTORY)
endef

# Define una funcion para crear la estructura de carpetas
#define COPY_BIOS
#	@echo	''
#	@echo	'-----> Copiando bios al path del bochs'
#
#	cp $(OUTPUT_BIN) $(BIOS)
#endef









# ******************************************************************** #
# ****************************** Reglas ****************************** #
# ******************************************************************** #

all: crearEstructura clean compilar
	@echo	''
	@echo	'Ejecutando bochs'
	bochs -f ./$(CARPETA_SUP)/$(BOCHSRC) -q
	rm *.ini

$(OUTPUT_BIN): $(ELFS)
	@echo	''
	@echo	'-----> Linkeando' $^ 'a binario'

	$(LINKER) $(LFLAGS) --oformat=binary $^ -o $@

	@echo	''
	@echo	'tamaño en bytes:'
	stat -c%s "$(OUTPUT_BIN)"

./$(CARPETA_OBJ)/%.elf: ./$(CARPETA_SRC)/%.asm
	@echo	''
	@echo	'-----> Compilando fuente en assembler' $<

	$(ASMC) $(ASMFLAGS) $< -o $@ -l $(subst $(CARPETA_OBJ)/,$(CARPETA_LST)/,$(@:.elf=.lst))


./$(CARPETA_OBJ)/%16.c.elf: ./$(CARPETA_SRC)/%16.c
	@echo	''
	@echo	'-----> Compilando fuente en C 16 bits' $<

	$(CC) -save-temps=obj $(CFLAGS16) $< -o $@


./$(CARPETA_OBJ)/%.c.elf: ./$(CARPETA_SRC)/%.c
	@echo	''
	@echo	'-----> Compilando fuente en C 32 bits' $<

	$(CC) -save-temps=obj $(CFLAGS) $< -o $@


.PHONY: compilar
compilar: clean $(OUTPUT_BIN)
	@echo	''
	@echo	'-----> Generando listados de hexadecimales y ELFs'

	hexdump -C $(OUTPUT_BIN) > ./$(CARPETA_TXT)/$(OUTPUT_NAME)_hexdump.txt
	objdump $(ODFLAGS) $(ELFS) > ./$(CARPETA_TXT)/$(OUTPUT_NAME)_objdump.txt
	readelf -a $(ELFS) > ./$(CARPETA_TXT)/$(OUTPUT_NAME)_readelf.txt

	@echo	''
	@echo	''
	@echo	'LISTO! n_n'
	@echo	''


.PHONY: crearEstructura
crearEstructura: $(DIRECTORY)

$(DIRECTORY):
	$(CREAR_ESTRUCTURA)



EXTENSIONES = bin elf o lst log ini i
clean:
	@echo	''
	@echo	'-----> Limpiando'

	rm -f $(foreach ext,$(EXTENSIONES), $(foreach dir,$(DIRECTORY),./$(dir)*.$(ext)))
	rm -f *.log
	rm -f *.ini
	rm -f log/*.*
	rm -f bin/*.txt


abrir_arhchivos:
	subl -n sup/linker_script.ld
	subl log/bios.map
	subl src/*.asm
