// Insertion Sort
#include <stdint.h>
extern unsigned int array_size;
extern short array_addr;
const short* array = &array_addr;
extern short _test_start;
short* dest = &_test_start;
int main() {
    short upper = 1, lower;
    short ref;
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