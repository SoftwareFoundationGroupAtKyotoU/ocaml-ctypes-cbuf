#include <stdint.h>

typedef uint32_t ip_addr_t;

extern int ip_addr_pton(const char *p, ip_addr_t *n);
