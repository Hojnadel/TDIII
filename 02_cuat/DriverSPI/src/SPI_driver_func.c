

void print_status_registers(volatile void* spi0_base_map){
   
   uint32_t status = 0;

   status = ioread32(spi0_base_map + MCSPI_CH0STAT);
   if(((status>>2)&1)==1)
      printk(KERN_INFO "... EOT: Transmision ended...\n");
   else
      printk(KERN_INFO "... EOT: Transmision not ended...\n");

   if(((status>>1)&1)==1)
      printk(KERN_INFO "... TXS: Transmision register empty ...\n");
   else
      printk(KERN_INFO "... TXS: Transmision register full ...\n");

   if(((status)&1)==1)
      printk(KERN_INFO "... RXS: Receiver register full ...\n");
   else
      printk(KERN_INFO "... RXS: Receiver register empty ...\n");   
   //status = ioread32(spi0_base_map + MCSPI_RX0);
   
}


/*** Settea el pin CS0 ***/
void cs0_action(volatile void * spi0_base_map, int action){
   int32_t status;

   status = ioread32(spi0_base_map + MCSPI_CH0CONF_OFFSET);
   if(action)
      status &=  ~FORCE; // BAJO LA LINEA CS
   else
      status |= FORCE;  //LEVANTO LA LINEA CS
   iowrite32(status, spi0_base_map + MCSPI_CH0CONF_OFFSET);
   ndelay(10);
}


/*** Mi función para pasar de string a int ***/
short mi_atoh(char* cadena){
   int hexnum = 0;
   int i=0;

   if(cadena[1] == 'x' || cadena[1]=='X')
      i=2;

   for(; cadena[i]; i++){
      hexnum = (hexnum<<4);
      if( cadena[i]>= '0' && cadena[i]<='9')
         hexnum |= cadena[i]-'0';
      else if( cadena[i]>='A' && cadena[i]<='F')
         hexnum |= (cadena[i]-'A'+0xA);
      else if(cadena[i]>='a' && cadena[i]<='f')
         hexnum |= (cadena[i]-'a'+0xA);
      else{
         printk(KERN_INFO "... Error in mi_atoi ...\n");
         return -1;
      }
   }
   return hexnum;
}

