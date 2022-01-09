module C = Bindings.C(Cbuf_gen)

exception IP_addr_error

let () =
  let ret = C.IP.ip_addr_pton "192.168.0.1" in
  Bytes.iter (fun c -> print_int (Char.code c); print_char '.') ret;
  print_endline "";

  let out1, (out2, out3) = C.multi_buffer (Unsigned.UInt64.of_int 42) in
  List.iter (fun out ->
    let i = Bytes.get_int64_le out 0 in
    Format.printf "%Ld\n" i )
    [out1; out2; out3]
