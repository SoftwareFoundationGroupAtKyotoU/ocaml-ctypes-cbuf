#include <stdint.h>

typedef uint32_t ip_addr_t;

extern int ip_addr_pton(const char *p, ip_addr_t *n);
extern int int_as_buffer(int *i);
extern void multi_buffer(uint64_t in, uint64_t *out1, uint64_t *out2,
                         uint64_t *out3);
extern int last_cbuf(int in, unsigned char *out1, unsigned char *out2);
extern int first_cbuf(unsigned char *out1, unsigned char *out2, int in);
extern int cbuf_only(unsigned char *out1);

extern void arity1(int in, unsigned char *out1);
extern void arity2(int in, unsigned char *out1, unsigned char *out2);
extern void arity3(int in, unsigned char *out1, unsigned char *out2,
                   unsigned char *out3);
