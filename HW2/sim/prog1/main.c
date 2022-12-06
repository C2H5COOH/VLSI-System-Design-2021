// William sucks
// #include <stdint.h>
// extern const uint32_t array_size;    
// extern const int32_t array_addr;
// extern int32_t _test_start;

// const int32_t* array = &array_addr;
// int32_t* result = &_test_start;

// int main(){
//     int i;
//     for(i = 0;i < array_size;i++){
//         result[i] = array[i];
//     }

//     int j,k;
//     int32_t tmp;
//     for(j = 0;j < array_size;j++){
//         for(k = 0;k < array_size-j-1;k++){
//             if(result[k] > result[k+1]){
//                 tmp = result[k];
//                 result[k] = result[k+1];
//                 result[k+1] = tmp;
//             }
//         }
//     }
//     return 0;
// }

// Parker good
#include <stdint.h>
extern const uint32_t array_size;
extern const int32_t  array_addr;
const int32_t* array = &array_addr;
extern int32_t _test_start;
int32_t* dest = &_test_start;
int main() {
    int32_t upper = 1, lower;
    int32_t ref;
    dest[0] = array[0];
    while (upper < array_size) { /* Insert the element at upper */
        lower = upper - 1;
        ref = array[upper];
        while (lower >= 0 && ref < dest[lower]) {
            dest[lower + 1] = dest[lower];
            lower --;
        }
        dest[lower + 1] = ref;
        upper ++;
    }
    return 0;
}

// Johnson?
// int main()
// {
//     extern int array_size;
//     extern int array_addr;
//     extern int _test_start;
//     int tmp;

//     // Bublle Sort
//     for (int i = 0; i < (array_size - 1); i++)
//     {
//         for (int j = 0; j < ((array_size - 1) - i); j++)
//         {
//             if (*(&array_addr + j) > *(&array_addr + j + 1))
//             {
//                 tmp = *(&array_addr + j);
//                 *(&array_addr + j) = *(&array_addr + j + 1);
//                 *(&array_addr + j + 1) = tmp;
//             }
//         }
//     }
//     // Store sort result
//     for (int i = 0; i < array_size; i++)
//     {
//         *(&_test_start + i) = *(&array_addr + i);
//     }
//     return 0;
// }