module CI = Cstubs_internals

external caml__1_ip_addr_pton : _ CI.fatptr -> bytes CI.ocaml -> int
  = "caml__1_ip_addr_pton" 

type 'a result = 'a
type 'a return = 'a
type 'a fn =
 | Returns  : 'a CI.typ   -> 'a return fn
 | Function : 'a CI.typ * 'b fn  -> ('a -> 'b) fn
let map_result f x = f x
let returning t = Returns t
let (@->) f p = Function (f, p)
let foreign : type a b. string -> (a -> b) fn -> (a -> b) =
  fun name t -> match t, name with
| Function
    (CI.View {CI.ty = CI.Pointer _; write = x2; _}, (* string *)
     Function (CI.Buffer 4, (* buffer 4 *)
     Returns (CI.Primitive CI.Int))), (* int *)
  "ip_addr_pton" ->
  (fun x1 _ ->
    let buf = Bytes.create 10 in
    let CI.CPointer x4 = x2 x1 in let x3 = x4 in 
    caml__1_ip_addr_pton x3 (Ctypes.ocaml_bytes_start buf))
| _, s ->  Printf.ksprintf failwith "No match for %s" s


let foreign_value : type a. string -> a Ctypes.typ -> a Ctypes.ptr =
  fun name t -> match t, name with
| _, s ->  Printf.ksprintf failwith "No match for %s" s
