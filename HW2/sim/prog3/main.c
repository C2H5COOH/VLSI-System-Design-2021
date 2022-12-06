#include <stdint.h>
extern const uint32_t div1;
extern const uint32_t div2;
extern int64_t _test_start;

int main(){
    uint32_t c = div1;
    uint32_t d = div2;

    uint32_t* result = &_test_start;
    while(c && d){
        if( c >= d )      c = c%d;
        else if( d > c )  d = d%c;
     }

    if( c >= d ) *result = c;
    
    else         *result = d;
    
    return 0;
}