#include <stddef.h>

void *__wrap_malloc(size_t size) {
    (void)size;
    extern void ERROR_heap_allocation_disabled(void);
    ERROR_heap_allocation_disabled();
    return NULL;
}

void *__wrap_calloc(size_t nmemb, size_t size) {
    (void)nmemb;
    (void)size;
    extern void ERROR_heap_allocation_disabled(void);
    ERROR_heap_allocation_disabled();
    return NULL;
}

void *__wrap_realloc(void *ptr, size_t size) {
    (void)ptr;
    (void)size;
    extern void ERROR_heap_allocation_disabled(void);
    ERROR_heap_allocation_disabled();
    return NULL;
}

void __wrap_free(void *ptr) {
    (void)ptr;
    // free() is OK to call (does nothing), so just ignore
}