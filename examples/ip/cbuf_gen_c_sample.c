#include "ctypes_cstubs_internals.h"
#include "ip_addr_pton.h"
value caml__1_ip_addr_pton(value x1, value x2) {
  char* x3 = CTYPES_ADDR_OF_FATPTR(x1);
  unsigned char* x4 = CTYPES_PTR_OF_OCAML_BYTES(x2);
  int x5 = ip_addr_pton(x3, x4);
  return Val_long(x5);
}
