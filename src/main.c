#include "stm32u5xx_hal.h"

int main(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    
    /* Initialize HAL (initializes SysTick for HAL_Delay) */
    HAL_Init();
    
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
        HAL_Delay(500);  /* Accurate 500ms delay */
    }
}

/* SysTick interrupt handler - required for HAL_Delay() */
void SysTick_Handler(void)
{
    HAL_IncTick();
}