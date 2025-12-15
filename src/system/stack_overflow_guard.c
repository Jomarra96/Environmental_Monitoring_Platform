// Initialize stack overflow guard for ARM Cortex-M. 
// Use only in dev/testing. Disable in makefile for production.
#include <stdint.h>

// Canary value (ideally randomized at boot, to avoid attackers predicting it)
uintptr_t __stack_chk_guard = 0xDEADBEEF;

// Called when stack smashing detected
__attribute__((noreturn))
void __stack_chk_fail(void) {
    // Log, blink LED, trigger watchdog, w/e
    extern void __disable_irq();
    while (1);
}