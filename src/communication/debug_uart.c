/**
 * @file debug_uart.c
 * @brief Debug UART output via USART1 (ST-Link VCP)
 *
 * USART1: PA9 (TX), PA10 (RX) - connected to ST-Link VCP on Nucleo
 */

#include <stdint.h>
#include "debug_uart.h"

#ifdef HOST_TEST
/* Host-only stubs - no HAL dependency */
#else
#include "stm32u5xx_hal.h"

static UART_HandleTypeDef huart1;
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

#ifndef HOST_TEST
/*
 * Initialize USART1 for debug output
 * PA9 = TX, PA10 = RX, 115200 8N1
 */
int Debug_UART_Init(void)
{
    GPIO_InitTypeDef gpio = {0};

    /* Enable clocks */
    __HAL_RCC_USART1_CLK_ENABLE();
    __HAL_RCC_GPIOA_CLK_ENABLE();

    /* Configure PA9 (TX) and PA10 (RX) as AF7 (USART1) */
    gpio.Pin = GPIO_PIN_9 | GPIO_PIN_10;
    gpio.Mode = GPIO_MODE_AF_PP;
    gpio.Pull = GPIO_NOPULL;
    gpio.Speed = GPIO_SPEED_FREQ_LOW;
    gpio.Alternate = GPIO_AF7_USART1;
    HAL_GPIO_Init(GPIOA, &gpio);

    /* Configure UART */
    huart1.Instance = USART1;
    huart1.Init.BaudRate = 115200;
    huart1.Init.WordLength = UART_WORDLENGTH_8B;
    huart1.Init.StopBits = UART_STOPBITS_1;
    huart1.Init.Parity = UART_PARITY_NONE;
    huart1.Init.Mode = UART_MODE_TX_RX;
    huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
    huart1.Init.OverSampling = UART_OVERSAMPLING_16;

    if (HAL_UART_Init(&huart1) != HAL_OK) {
        return -1;
    }

    return 0;
}

void Debug_SendChar(char c)
{
    HAL_UART_Transmit(&huart1, (uint8_t *)&c, 1, HAL_MAX_DELAY);
}

void Debug_SendString(const char *str)
{
    while (*str) {
        Debug_SendChar(*str++);
    }
}

void Debug_SendInt(int32_t value)
{
    char buf[12];
    if (int_to_string(value, buf, sizeof(buf)) > 0) {
        Debug_SendString(buf);
    }
}

void Debug_SendUInt(uint32_t value)
{
    char buf[11];
    if (uint_to_string(value, buf, sizeof(buf)) > 0) {
        Debug_SendString(buf);
    }
}

void Debug_SendNewline(void)
{
    Debug_SendString("\r\n");
}

#endif /* HOST_TEST */
