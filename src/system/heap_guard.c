#include <stddef.h>

extern void ERROR_heap_allocation_disabled(void);

void *__wrap_malloc(size_t size) {
    (void)size;
    ERROR_heap_allocation_disabled();
    return NULL;
}

void *__wrap_calloc(size_t nmemb, size_t size) {
    (void)nmemb;
    (void)size;
    ERROR_heap_allocation_disabled();
    return NULL;
}

void *__wrap_realloc(void *ptr, size_t size) {
    (void)ptr;
    (void)size;
    ERROR_heap_allocation_disabled();
    return NULL;
}

void __wrap_free(void *ptr) {
    (void)ptr;
    ERROR_heap_allocation_disabled();
}