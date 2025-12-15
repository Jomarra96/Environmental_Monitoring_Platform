#include <stddef.h>
#include "stm32u5xx_hal.h"

// Your UART handle (declare extern, defined in main.c or uart.c)
extern UART_HandleTypeDef huart2;

// Custom write implementation. Only for debugging, using printf().
// NOTE: Disable in production.
int _write(int file, char *ptr, int len) {
    (void)file;
    HAL_UART_Transmit(&huart2, (uint8_t *)ptr, (uint16_t)len, HAL_MAX_DELAY);
    return len;
}

// Custom read implementation. Only for automated testing.
// NOTE: Disable in production.
int _read(int file, char *ptr, int len) {
    (void)file;
    HAL_StatusTypeDef status;
    
    for (int i = 0; i < len; i++) {
        status = HAL_UART_Receive(&huart2, (uint8_t *)&ptr[i], 1, 1000); // 1s timeout
        if (status != HAL_OK) {
            return i;  // return what we got
        }
        if (ptr[i] == '\r' || ptr[i] == '\n') {
            ptr[i] = '\n';
            return i + 1;
        }
    }
    return len;
}