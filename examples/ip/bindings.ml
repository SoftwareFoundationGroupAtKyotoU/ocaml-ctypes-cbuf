open Ctypes
open Cbuf

module C(F: Cbuf.FOREIGN) = struct
  open F

  module IP = struct
    let ip_addr_pton = 
      foreign "ip_addr_pton" (string @-> retbuf (buffer 4 ocaml_bytes) (returning int))
  end

  let multi_buffer = foreign "multi_buffer" 
    (uint64_t @-> retbuf (buffer 8 ocaml_bytes @* buffer 8 ocaml_bytes @* buffer 8 ocaml_bytes) (returning void))
  
  let last_cbuf = foreign "last_cbuf"
    (int @-> retbuf (buffer 4 ocaml_bytes @* buffer 8 ocaml_bytes) (returning void))
  
  let first_cbuf = foreign "first_cbuf" 
    (int @-> retbuf ~cposition:`First (buffer 4 ocaml_bytes @* buffer 8 ocaml_bytes) (returning int))
end
