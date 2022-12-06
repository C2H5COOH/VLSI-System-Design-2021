void boot() {
  extern unsigned int _dram_i_start;
  extern unsigned int _dram_i_end;
  extern unsigned int _imem_start;

  extern unsigned int __sdata_start;
  extern unsigned int __sdata_end;
  extern unsigned int __sdata_paddr_start;

  extern unsigned int __data_start;
  extern unsigned int __data_end;
  extern unsigned int __data_paddr_start;
  int *ptr1, *ptr2;
    // IM
    ptr1 = &_imem_start;
    ptr2 = &_dram_i_start;
    do 
    {
        *ptr1 = *ptr2;
        ++ptr1;
        ++ptr2;
    } while (ptr2 <= &_dram_i_end);
    // DM
    ptr1 = &__sdata_paddr_start;
    ptr2 = &__sdata_start;
    do 
    {
        *ptr2 = *ptr1;
        ++ptr1;
        ++ptr2;
    } while (ptr2 <= &__sdata_end);
    // DM
    ptr1 = &__data_paddr_start;
    ptr2 = &__data_start;
    do 
    {
        *ptr2 = *ptr1;
        ++ptr1;
        ++ptr2;
    } while (ptr2 <= &__data_end);
}
