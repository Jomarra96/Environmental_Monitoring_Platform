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
    char tmp[12]; /* -2147483648 = 11 chars + null */
    uint8_t i = 0;
    uint8_t neg = 0;
    uint32_t uval;

    if (buf_size == 0) return -1;

    /* Handle negative */
    if (value < 0) {
        neg = 1;
        uval = (uint32_t)(-(value + 1)) + 1; /* avoid overflow on INT32_MIN */
    } else {
        uval = (uint32_t)value;
    }

    /* Build string in reverse */
    do {
        tmp[i++] = (char)('0' + (uval % 10));
        uval /= 10;
    } while (uval > 0);

    if (neg) tmp[i++] = '-';

    /* Check buffer size (need space for null) */
    if (i >= buf_size) return -1;

    /* Reverse copy to output */
    uint8_t len = i;
    while (i > 0) {
        *buf++ = tmp[--i];
    }
    *buf = '\0';

    return (int)len;
}

/*
 * Convert uint32_t to string
 * Returns: string length, or -1 if buffer too small
 */
int uint_to_string(uint32_t value, char *buf, uint8_t buf_size)
{
    char tmp[11]; /* 4294967295 = 10 chars + null */
    uint8_t i = 0;

    if (buf_size == 0) return -1;

    /* Build string in reverse */
    do {
        tmp[i++] = (char)('0' + (value % 10));
        value /= 10;
    } while (value > 0);

    /* Check buffer size */
    if (i >= buf_size) return -1;

    /* Reverse copy to output */
    uint8_t len = i;
    while (i > 0) {
        *buf++ = tmp[--i];
    }
    *buf = '\0';

    return (int)len;
}
