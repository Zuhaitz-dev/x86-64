
#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>   // For printing 64-bit integers portably.

// Just a function prototype.
// This promises the compiler that a function named
// "array_max" exists somewhere.
extern int64_t array_max(int64_t* array, int64_t count);

int main(void)
{
    int64_t my_data[] = {34, 12, 99, 7, 50, 101, 88, -5, 200};
    int64_t num_elements = sizeof(my_data) / sizeof(my_data[0]);

    printf("Calling assembly function to find the max value.\n");

    int64_t result = array_max(my_data, num_elements);

    printf("Assembly function returned: %" PRId64 "\n", result);

    return 0;
}