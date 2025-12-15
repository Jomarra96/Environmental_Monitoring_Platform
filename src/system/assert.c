#include <stdint.h>

#ifdef USE_FULL_ASSERT
void assert_failed(uint8_t *file, uint32_t line) {
    (void)file;
    (void)line;
    extern void __disable_irq();
    while (1);
}
#endif