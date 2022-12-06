int main(void) {
    extern char _test_start;
    extern char _binary_image_bmp_start;
    extern char _binary_image_bmp_end;
    extern unsigned int _binary_image_bmp_size;

    int array;
    for(array=0;array<54;array++)
        *(&_test_start+array)=*(&_binary_image_bmp_start+array);
    
    unsigned int size=(unsigned int)(&_binary_image_bmp_size);
    
    for(;array<size;array=array+3){
        char *a0,*a1,*a2;
        a0=&_test_start+array;
        a1=a0+1;
        a2=a0+2;
        char *now_data_address=&_binary_image_bmp_start+array;
         
        if ( (*(now_data_address)==*(now_data_address+1))
            &(*(now_data_address)==*(now_data_address+2)) ){
            char temp=*(now_data_address);
            *(a0)=temp;
            *(a1)=temp; 
            *(a2)=temp; 
        }
        else{              
            char temp=( (*(now_data_address)*11
                         +*(now_data_address+1)*59
                         +*(now_data_address+2)*30)   /100);

            *(a0)=temp;
            *(a1)=temp;
            *(a2)=temp;
        }     
    }      
    return 0;
    
}















/*int main(void) {
    extern char _test_start;
    extern char _binary_image_bmp_start;
    extern char _binary_image_bmp_end;
    extern unsigned int _binary_image_bmp_size;
    for(unsigned int i=0;i<54;i++)
        *(&_test_start+i)=*(&_binary_image_bmp_start+i);

    
    
    unsigned int size=(unsigned int)(&_binary_image_bmp_size);
    
    for(unsigned int array=54;array<size;array=array+3){
         char *a0,*a1,*a2;
         a0=&_test_start+array;
         a1=a0+1;
         a2=a0+2;
         char *now_data_address=&_binary_image_bmp_start+array;
         if ( (*(now_data_address)==*(now_data_address+1))
            &(*(now_data_address)==*(now_data_address+2)) ){
             char temp=*(now_data_address);
             *(a0)=temp;
             *(a1)=temp; 
             *(a2)=temp; 
             }
            else
             {
              //char *addr=&_binary_image_bmp_start+array;
              float f0=*(now_data_address)*0.11;
              float f1=*(now_data_address+1)*0.59;
              float f2=*(now_data_address+2)*0.3;
              float fin=f0+f1+f2;
              char temp=(char)fin;

              *(a0)=temp;
              *(a1)=temp;
              *(a2)=temp;
             } 
    
    }
    
        
    unsigned int left=4-size%4;
    for(unsigned int i=0;i<left;i++){
       *((char*)&_test_start+size+i)=0;
    }
       
    return 0;
    
}*/

