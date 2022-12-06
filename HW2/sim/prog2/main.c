#include <stdint.h>
extern const int32_t mul1;
extern const int32_t mul2;
extern int64_t _test_start;

int64_t* result = &_test_start;


int main(){
    int64_t i = mul1;
    int64_t j = mul2;
    *result = i * j;
    return 0;
}