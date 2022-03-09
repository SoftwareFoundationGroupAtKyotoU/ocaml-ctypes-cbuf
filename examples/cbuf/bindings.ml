open Ctypes
open Cbuf

module C (F : Cbuf.FOREIGN) = struct
  open F

  module IP = struct
    let ip_addr_pton =
      foreign "ip_addr_pton"
        (string @-> retbuf (buffer 4 ocaml_bytes) (returning int))
  end

  let multi_buffer =
    foreign "multi_buffer"
      (uint64_t
      @-> retbuf
            (buffer 8 ocaml_bytes @* buffer 8 ocaml_bytes
           @* buffer 8 ocaml_bytes)
            (returning void))

  let last_cbuf =
    foreign "last_cbuf"
      (int
      @-> retbuf (buffer 4 ocaml_bytes @* buffer 8 ocaml_bytes) (returning int)
      )

  let first_cbuf =
    foreign "first_cbuf"
      (int
      @-> retbuf ~cposition:`First
            (buffer 4 ocaml_bytes @* buffer 8 ocaml_bytes)
            (returning int))

  let cbuf_only =
    foreign "cbuf_only" (void @-> retbuf (buffer 4 ocaml_bytes) (returning int))

  let arity1 =
    foreign "arity1" (int @-> retbuf (buffer 4 ocaml_bytes) (returning void))

  let arity1_ = foreign "arity1" (int @-> ocaml_bytes @-> returning void)

  let arity2 =
    foreign "arity2"
      (int
      @-> retbuf (buffer 4 ocaml_bytes @* buffer 4 ocaml_bytes) (returning void)
      )

  let arity2_ =
    foreign "arity2" (int @-> ocaml_bytes @-> ocaml_bytes @-> returning void)

  let arity3 =
    foreign "arity3"
      (int
      @-> retbuf
            (buffer 4 ocaml_bytes @* buffer 4 ocaml_bytes
           @* buffer 4 ocaml_bytes)
            (returning void))

  let arity3_ =
    foreign "arity3"
      (int @-> ocaml_bytes @-> ocaml_bytes @-> ocaml_bytes @-> returning void)

  let memcpy_ctypes =
    foreign "memcpy" (ocaml_bytes @-> ocaml_bytes @-> size_t @-> returning void)

  let memcpy_cbuf =
    foreign "memcpy"
      (ocaml_bytes @-> size_t
      @-> retbuf ~cposition:`First (buffer 100 ocaml_bytes) (returning void))
end
