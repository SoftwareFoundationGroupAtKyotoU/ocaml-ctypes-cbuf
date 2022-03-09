let () =
  let fmt = Format.formatter_of_out_channel (open_out "cbuf_gen.c") in
  Format.fprintf fmt "#include \"example.h\"\n#include <string.h>\n";
  Cbuf.write_c fmt ~prefix:"caml_" (module Bindings.C);

  let fmt = Format.formatter_of_out_channel (open_out "cbuf_gen.ml") in
  Cbuf.write_ml fmt ~prefix:"caml_" (module Bindings.C)
