module CI = Cstubs_internals

external caml__1_ip_addr_pton : _ CI.fatptr -> bytes CI.ocaml -> int
  = "caml__1_ip_addr_pton" 

external caml__2_multi_buffer
  : Unsigned.uint64 -> bytes CI.ocaml -> bytes CI.ocaml -> bytes CI.ocaml ->
    Signed.sint = "caml__2_multi_buffer"

type 'a result = 'a
type 'a return = 'a
type 'a fn =
 | Returns  : 'a CI.typ   -> 'a return fn
 | Function : 'a CI.typ * 'b fn  -> ('a -> 'b) fn
 | Buffers : ('a, 'b) CI.pointer CI.cbuffers -> 'a fn (* TODO: *)
let map_result f x = f x
let returning t = Returns t
let retbuf b = Buffers b
let (@->) f p = Function (f, p)
let foreign : type a b. string -> (a -> b) fn -> (a -> b) =
  fun name t -> match t, name with
| Function
    (CI.View {CI.ty = CI.Pointer _; write = x2; _}, Buffers (LastBuf (4, OCaml Bytes) )),
  "ip_addr_pton" ->
  (fun x1 ->
    let buf1 = Bytes.create 4 in
    let CI.CPointer x4 = x2 x1 in let x3 = x4 in 
    let _ = caml__1_ip_addr_pton x3 (Ctypes.ocaml_bytes_start buf1) in
    buf1)
| Function
    (CI.Primitive CI.Uint64_t,
     Buffers
       (ConBuf
          (LastBuf (8, CI.OCaml CI.Bytes),
           ConBuf
             (LastBuf (8, CI.OCaml CI.Bytes), LastBuf (8, CI.OCaml CI.Bytes))))),
  "multi_buffer" ->
  (fun x1 ->
    let x4 = Bytes.create 8 in
    let x3 = Bytes.create 8 in
    let x2 = Bytes.create 8 in
    let _
    = caml__2_multi_buffer x1 (Ctypes.ocaml_bytes_start x2)
      (Ctypes.ocaml_bytes_start x3) (Ctypes.ocaml_bytes_start x4)
    in (x2, (x3, x4)))
| _, s ->  Printf.ksprintf failwith "No match for %s" s


let foreign_value : type a. string -> a Ctypes.typ -> a Ctypes.ptr =
  fun name t -> match t, name with
| _, s ->  Printf.ksprintf failwith "No match for %s" s
