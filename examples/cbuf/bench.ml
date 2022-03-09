module C = Bindings.C (Cbuf_gen)

let cases =
  [
    ( ( (fun () ->
          let _ = C.arity1 1 in
          ()),
        "arity1" ),
      ( (fun () ->
          let _ =
            (fun () ->
              let b1 = Bytes.create 4 in
              let ret = C.arity1_ 1 (Ctypes.ocaml_bytes_start b1) in
              (b1, ret))
              ()
          in
          ()),
        "arity1_" ) );
    ( ( (fun () ->
          let _ = C.arity2 1 in
          ()),
        "arity2" ),
      ( (fun () ->
          let _ =
            (fun () ->
              let b1 = Bytes.create 4 in
              let b2 = Bytes.create 4 in
              let ret =
                C.arity2_ 1
                  (Ctypes.ocaml_bytes_start b1)
                  (Ctypes.ocaml_bytes_start b2)
              in
              (b1, b2, ret))
              ()
          in
          ()),
        "arity2_" ) );
    ( ( (fun () ->
          let _ = C.arity3 1 in
          ()),
        "arity3" ),
      ( (fun () ->
          let _ =
            (fun () ->
              let b1 = Bytes.create 4 in
              let b2 = Bytes.create 4 in
              let b3 = Bytes.create 4 in
              let ret =
                C.arity3_ 1
                  (Ctypes.ocaml_bytes_start b1)
                  (Ctypes.ocaml_bytes_start b2)
                  (Ctypes.ocaml_bytes_start b3)
              in
              (b1, b2, b3, ret))
              ()
          in
          ()),
        "arity3_" ) );
  ]

let bench ((exp1, name1), (exp2, name2)) =
  let n2 = ref (Printf.sprintf "%s," name2) in
  Printf.printf "%s," name1;
  for _ = 1 to 100 do
    let s1 = Sys.time () in
    for _ = 1 to 1000000 do
      exp1 ()
    done;
    let e1 = Sys.time () in
    let s2 = Sys.time () in
    for _ = 1 to 1000000 do
      exp2 ()
    done;
    let e2 = Sys.time () in
    Printf.printf "%f," (e1 -. s1);
    n2 := !n2 ^ Printf.sprintf "%f," (e2 -. s2)
  done;
  print_newline ();
  print_endline !n2

let () = List.iter bench cases
