/**
 * @file debug_uart.h
 * @brief Debug UART output via USART1 (ST-Link VCP on Nucleo)
 *
 * Pins: PA9 (TX), PA10 (RX)
 * Config: 115200 8N1
 */

#ifndef DEBUG_UART_H
#define DEBUG_UART_H

#include <stdint.h>

/**
 * Initialize USART1 for debug output
 * @return 0 on success, -1 on failure
 */
int Debug_UART_Init(void);

/**
 * Send null-terminated string
 * @param str String to send
 */
void Debug_SendString(const char *str);

/**
 * Send single character
 * @param c Character to send
 */
void Debug_SendChar(char c);

/**
 * Send signed integer as string
 * @param value Integer value
 */
void Debug_SendInt(int32_t value);

/**
 * Send unsigned integer as string
 * @param value Unsigned value
 */
void Debug_SendUInt(uint32_t value);

/**
 * Send newline (CRLF)
 */
void Debug_SendNewline(void);

/* Internal conversion functions (exposed for testing) */
int int_to_string(int32_t value, char *buf, uint8_t buf_size);
int uint_to_string(uint32_t value, char *buf, uint8_t buf_size);

#endif /* DEBUG_UART_H */
