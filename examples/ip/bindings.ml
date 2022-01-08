open Ctypes

module C(F: Ctypes.FOREIGN) = struct
  open F
  module IP = struct
    let ip_addr_pton = 
      foreign "ip_addr_pton" (string @-> retbuf (buffer 4 ocaml_bytes))
  end

  let multi_buffer = foreign "multi_buffer" 
    (uint64_t @-> retbuf (buffer 8 ocaml_bytes @* buffer 8 ocaml_bytes))

  (* let hoge = foreign "hoge" (ptr int @-> ptr char @-> returning int) *)
  (* let fuga = foreign "fuga" (ocaml_bytes @-> retbuf (buffer 4 ocaml_string)) *)

  (* let int_as_buffer =
    foreign "int_as_buffer" retbuf (buffer 4 int) *)

  (* let multi_buffer = foreign "multi_buffer" (string @-> retbuf (buffer 4 ocaml_bytes @* buffer 3 int @* buffer 1 char @* buffer 9 ocaml_bytes)) *)

  (* let hoge = foreign "hoge" (string @-> returning int) *)
end
