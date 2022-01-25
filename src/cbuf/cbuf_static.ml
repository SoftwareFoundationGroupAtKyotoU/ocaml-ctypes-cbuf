type cposition = [ `First | `Last ]

type _ fn =
  | Returns : 'a Ctypes.typ -> 'a fn
  | Function : 'a Ctypes.typ * 'b fn -> ('a -> 'b) fn
  | Buffers :
      cposition * ('a, 'b) Ctypes.pointer cbuffers * 'c fn
      -> ('a * 'c) fn

and _ cbuffers =
  | LastBuf :
      int * ('a, 'b) Ctypes.pointer Ctypes.typ
      -> ('a, 'b) Ctypes.pointer cbuffers
  | ConBuf :
      ('a, 'b) Ctypes.pointer cbuffers * ('c, 'd) Ctypes.pointer cbuffers
      -> ('a * 'c, [ `Mixed ]) Ctypes.pointer cbuffers

let ( @* ) l r = ConBuf (l, r)
let retbuf ?(cposition = `Last) buf return = Buffers (cposition, buf, return)
let buffer i ty = LastBuf (i, ty)

let ( @-> ) f t =
  if not (Ctypes.passable f) then
    raise (Ctypes.Unsupported "Unsupported argument type")
  else Function (f, t)

let returning v =
  if not (Ctypes.passable v) then
    raise (Ctypes.Unsupported "Unsupported return type")
  else Returns v
