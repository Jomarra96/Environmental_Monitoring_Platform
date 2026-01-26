/**
 * @file test_debug_uart.c
 * @brief Host-side unit tests for debug_uart conversion functions
 *
 * Compile: gcc -DHOST_TEST -I../src/communication tests/test_debug_uart.c \
 *              src/communication/debug_uart.c -o tests/test_uart && ./tests/test_uart
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>

/* Function prototypes - will be implemented in debug_uart.c */
int int_to_string(int32_t value, char *buf, uint8_t buf_size);
int uint_to_string(uint32_t value, char *buf, uint8_t buf_size);

static int tests_passed = 0;
static int tests_failed = 0;

#define TEST_ASSERT(cond, msg) do { \
    if (cond) { \
        tests_passed++; \
        printf("  PASS: %s\n", msg); \
    } else { \
        tests_failed++; \
        printf("  FAIL: %s\n", msg); \
    } \
} while(0)

/* Test int_to_string */
void test_int_to_string(void)
{
    char buf[16];
    int len;

    printf("\n=== test_int_to_string ===\n");

    /* Positive numbers */
    len = int_to_string(0, buf, sizeof(buf));
    TEST_ASSERT(len == 1 && strcmp(buf, "0") == 0, "0 -> \"0\"");

    len = int_to_string(1, buf, sizeof(buf));
    TEST_ASSERT(len == 1 && strcmp(buf, "1") == 0, "1 -> \"1\"");

    len = int_to_string(123, buf, sizeof(buf));
    TEST_ASSERT(len == 3 && strcmp(buf, "123") == 0, "123 -> \"123\"");

    len = int_to_string(2147483647, buf, sizeof(buf));
    TEST_ASSERT(len == 10 && strcmp(buf, "2147483647") == 0, "INT32_MAX");

    /* Negative numbers */
    len = int_to_string(-1, buf, sizeof(buf));
    TEST_ASSERT(len == 2 && strcmp(buf, "-1") == 0, "-1 -> \"-1\"");

    len = int_to_string(-123, buf, sizeof(buf));
    TEST_ASSERT(len == 4 && strcmp(buf, "-123") == 0, "-123 -> \"-123\"");

    len = int_to_string(-2147483648, buf, sizeof(buf));
    TEST_ASSERT(len == 11 && strcmp(buf, "-2147483648") == 0, "INT32_MIN");

    /* Buffer too small */
    len = int_to_string(12345, buf, 3);
    TEST_ASSERT(len == -1, "buffer too small returns -1");
}

/* Test uint_to_string */
void test_uint_to_string(void)
{
    char buf[16];
    int len;

    printf("\n=== test_uint_to_string ===\n");

    len = uint_to_string(0, buf, sizeof(buf));
    TEST_ASSERT(len == 1 && strcmp(buf, "0") == 0, "0 -> \"0\"");

    len = uint_to_string(1, buf, sizeof(buf));
    TEST_ASSERT(len == 1 && strcmp(buf, "1") == 0, "1 -> \"1\"");

    len = uint_to_string(4294967295U, buf, sizeof(buf));
    TEST_ASSERT(len == 10 && strcmp(buf, "4294967295") == 0, "UINT32_MAX");

    /* Buffer too small */
    len = uint_to_string(12345, buf, 3);
    TEST_ASSERT(len == -1, "buffer too small returns -1");
}

int main(void)
{
    printf("Debug UART Unit Tests\n");
    printf("=====================\n");

    test_int_to_string();
    test_uint_to_string();

    printf("\n=====================\n");
    printf("Results: %d passed, %d failed\n", tests_passed, tests_failed);

    return tests_failed > 0 ? 1 : 0;
}
