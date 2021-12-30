module C = Bindings.C(Cstubs_gen_sample)

exception IP_addr_error
let () =
  let ret = C.IP.ip_addr_pton "192.168.0.1" in
  Bytes.iter (fun c -> print_int (Char.code c); print_char '.') ret
