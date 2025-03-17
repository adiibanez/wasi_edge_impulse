#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "../ei_classifier_porting.h"

extern "C" void ei_printf(const char *format, ...) {
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);
}

extern "C" void ei_printf_float(float f) {
    printf("%f", f);
}

extern "C" void *ei_malloc(size_t size) {
    return malloc(size);
}

extern "C" void *ei_calloc(size_t nitems, size_t size) {
    return calloc(nitems, size);
}

extern "C" void ei_free(void *ptr) {
    free(ptr);
}

extern "C" void ei_putchar(char c) {
    putchar(c);
}

extern "C" char ei_getchar(void) {
    return getchar();
}

extern "C" uint64_t ei_read_timer_ms() {
    // TODO: Implement proper timer for WASI
    return 0;
}

extern "C" uint64_t ei_read_timer_us() {
    // TODO: Implement proper timer for WASI
    return 0;
}

extern "C" EI_IMPULSE_ERROR ei_sleep(int32_t time_ms) {
    // TODO: Implement proper sleep for WASI
    return EI_IMPULSE_OK;
}

extern "C" EI_IMPULSE_ERROR ei_run_impulse_check_canceled() {
    // For now, we never cancel impulse detection
    return EI_IMPULSE_OK;
}
