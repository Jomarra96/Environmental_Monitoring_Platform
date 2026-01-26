#include "stm32u5xx_hal.h"
#include "communication/debug_uart.h"

int main(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    uint32_t count = 0;

    /* Initialize HAL (initializes SysTick for HAL_Delay) */
    HAL_Init();

    /* Initialize debug UART */
    Debug_UART_Init();

    Debug_SendString("Boot OK");
    Debug_SendNewline();

    /* Enable GPIOC clock */
    __HAL_RCC_GPIOC_CLK_ENABLE();

    /* Configure PC7 (LED) as output */
    GPIO_InitStruct.Pin = GPIO_PIN_7;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

    /* Blink loop */
    while (1)
    {
        HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_7);
        Debug_SendString("Tick: ");
        Debug_SendUInt(count++);
        Debug_SendNewline();
        HAL_Delay(1000);
    }
}

/* SysTick interrupt handler - required for HAL_Delay() */
void SysTick_Handler(void)
{
    HAL_IncTick();
}