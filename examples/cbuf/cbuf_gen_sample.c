#include "ctypes_cstubs_internals.h"
#include "ip_addr_pton.h"
value caml__1_ip_addr_pton(value x1, value x2) {
  char* x3 = CTYPES_ADDR_OF_FATPTR(x1);
  unsigned char* x4 = CTYPES_PTR_OF_OCAML_BYTES(x2);
  int x5 = ip_addr_pton(x3, x4);
  return Val_long(x5);
}

value caml__2_multi_buffer(value x9, value x8, value x7, value x6) {
  uint64_t x10 = Uint64_val(x9);
  unsigned char* x13 = CTYPES_PTR_OF_OCAML_BYTES(x8);
  unsigned char* x14 = CTYPES_PTR_OF_OCAML_BYTES(x7);
  unsigned char* x15 = CTYPES_PTR_OF_OCAML_BYTES(x6);
  int x16 = multi_buffer(x10, x13, x14, x15);
  return Val_long(x16);
}
