/**
 * @file debug_uart.c
 * @brief Debug UART output via USART1 (ST-Link VCP)
 */

#include <stdint.h>

#ifdef HOST_TEST
/* Host-only stubs - no HAL dependency */
#else
#include "stm32u5xx_hal.h"
#endif

/*
 * Convert int32_t to string
 * Returns: string length, or -1 if buffer too small
 */
int int_to_string(int32_t value, char *buf, uint8_t buf_size)
{
    /* TODO: implement */
    (void)value;
    (void)buf;
    (void)buf_size;
    return -1;
}

/*
 * Convert uint32_t to string
 * Returns: string length, or -1 if buffer too small
 */
int uint_to_string(uint32_t value, char *buf, uint8_t buf_size)
{
    /* TODO: implement */
    (void)value;
    (void)buf;
    (void)buf_size;
    return -1;
}
