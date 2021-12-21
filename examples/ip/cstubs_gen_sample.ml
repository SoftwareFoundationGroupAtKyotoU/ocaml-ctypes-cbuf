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
    (CI.View {CI.ty = CI.Pointer _; write = x2; _},
     Function (CI.OCaml CI.Bytes, Returns (CI.Primitive CI.Int))),
  "ip_addr_pton" ->
  (fun x1 x5 ->
    let CI.CPointer x4 = x2 x1 in let x3 = x4 in caml__1_ip_addr_pton x3 x5)
| _, s ->  Printf.ksprintf failwith "No match for %s" s


let foreign_value : type a. string -> a Ctypes.typ -> a Ctypes.ptr =
  fun name t -> match t, name with
| _, s ->  Printf.ksprintf failwith "No match for %s" s
