open Ctypes

module C(F: Ctypes.FOREIGN) = struct
  open F
  module IP = struct
    let ip_addr_pton = 
      foreign "ip_addr_pton" (string @-> retbuf (buffer 4 ocaml_bytes))
  end

  let multi_buffer = foreign "multi_buffer" 
    (uint64_t @-> retbuf (buffer 8 ocaml_bytes @* buffer 8 ocaml_bytes @* buffer 8 ocaml_bytes))
end
