int main(void){
    extern int array_size_i;
    extern int array_size_j;
    extern int array_size_k;
    extern short array_addr;
    extern int _test_start;
    short *array0 = &array_addr, *array1 = array0 + array_size_i * array_size_k;
    int *test = &_test_start, tmp;
    int mult0, mult1;
    
    for (int i = 0, i_mult_k = 0, i_mult_j = 0; i < array_size_i; i ++, i_mult_k += array_size_k, i_mult_j += array_size_j) {
        for (int j = 0; j < array_size_j; j ++) {
            tmp = 0;
            for (int k = 0, k_mult_j = 0; k < array_size_k; k ++, k_mult_j += array_size_j) {
                mult0 = *(array0 + i_mult_k + k);
                mult1 = *(array1 + k_mult_j + j);
                tmp += mult0 * mult1;
            }
            *(test + j + i_mult_j) = tmp;
        }
    }
    return 0;
}
// int main(void)
// {
//     extern int array_size_i;
//     extern int array_size_j;
//     extern int array_size_k;
//     extern short array_addr;
//     extern int _test_start;


//     const short* matrix = &array_addr;
//     int* result = &_test_start;

//     int counter = 0;
//     int B_start_addr = array_size_i * array_size_k;

//     int i = 0;
//     int j = 0;
//     int k = 0;
//     for (i = 0; i < array_size_i; i++)
//     {
//         for (j = 0; j < array_size_j; j++)
//         {
//             for (k = 0; k < array_size_k; k++)
//             {
//                 result[counter] += (matrix[((i * array_size_k) + k)] * matrix[(B_start_addr + (k * array_size_j + j))]);
//             }
//             counter++;
//         }
//     }
//     return 0;
// }

// int main(void)
// {
//     extern int array_size_i;
//     extern int array_size_j;
//     extern int array_size_k;
//     extern short array_addr;
//     extern int _test_start;
//     short *array0 = &array_addr, *array1 = array0 + array_size_i * array_size_k;
//     int *test = &_test_start, tmp;
//     int mult0, mult1;
    
//     for (int i = 0, i_mult_k = 0, i_mult_j = 0; i < array_size_i; i ++, i_mult_k += array_size_k, i_mult_j += array_size_j) 
//     {
//         for (int j = 0; j < array_size_j; j ++) 
//         {
//             tmp = 0;
//             for (int k = 0, k_mult_j = 0; k < array_size_k; k ++, k_mult_j += array_size_j) 
//             {
//                 mult0 = *(array0 + i_mult_k + k);
//                 mult1 = *(array1 + k_mult_j + j);
//                 tmp += mult0 * mult1;
//             }
//             *(test + j + i_mult_j) = tmp;
//         }
//     }
//     return 0;
// }