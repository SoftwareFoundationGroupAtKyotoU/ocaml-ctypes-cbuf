module C = Bindings.C (Cbuf_gen)

exception IP_addr_error

let () =
  let ret, _ = C.IP.ip_addr_pton "192.168.0.1" in
  Bytes.iter
    (fun c ->
      print_int (Char.code c);
      print_char '.')
    ret;
  print_endline "";

  let (out1, (out2, out3)), _ = C.multi_buffer (Unsigned.UInt64.of_int 42) in
  List.iter
    (fun out ->
      let i = Bytes.get_int64_le out 0 in
      Format.printf "%Ld\n" i)
    [ out1; out2; out3 ];

  let (out1, out2), _ = C.last_cbuf 3 in
  List.iter
    (fun out ->
      let i = Bytes.get_int16_le out 0 in
      Format.printf "%d\n" i)
    [ out1; out2 ];

  let (out1, out2), ret = C.first_cbuf 4 in
  assert (ret = 0);
  List.iter
    (fun out ->
      let i = Bytes.get_int16_le out 0 in
      Format.printf "%d\n" i)
    [ out1; out2 ]
