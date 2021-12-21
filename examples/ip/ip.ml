module C = Bindings.C(Cstubs_gen_sample)

exception IP_addr_error
let () =
  let n = Bytes.create 4 in
  let ret = C.IP.ip_addr_pton "192.168.0.1" {length=0} in
  if ret <> 0 then raise IP_addr_error else
    Bytes.iter (fun c -> print_int (Char.code c); print_char '.') n
