#include "ip_addr_pton.h"

#include <stdint.h>
#include <stdlib.h>

int ip_addr_pton(const char *p, ip_addr_t *n) {
  char *sp, *ep;
  long ret;

  sp = (char *)p;
  for (int idx = 0; idx < 4; idx++) {
    ret = strtol(sp, &ep, 10);  // 10進数
    if (ret < 0 || ret > 255) {
      return -1;
    }
    if (ep == sp) {
      return -1;
    }
    if ((idx == 3 && *ep != '\0') || (idx != 3 && *ep != '.')) {
      return -1;
    }
    ((uint8_t *)n)[idx] = ret;
    sp = ep + 1;
  }
  return 0;
}

int int_as_buffer(int *i) {
  *i = 10;
  return 0;
}

void multi_buffer(uint64_t in, uint64_t *out1, uint64_t *out2, uint64_t *out3) {
  *out1 = in;
  *out2 = in << 1;
  *out3 = in << 2;
}

void last_cbuf(int in, unsigned char *out1, unsigned char *out2) {
  *out1 = in;
  *out2 = in << 1;
}

int first_cbuf(unsigned char *out1, unsigned char *out2, int in) {
  *out1 = in;
  *out2 = in << 1;
  return 0;
}
