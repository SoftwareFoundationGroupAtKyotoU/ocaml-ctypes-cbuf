(*
 * Copyright (c) 2014 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

(* C stub generation *)

open Ctypes_static
open Cbuf_c_language
open Unchecked_function_types

let max_byte_args = 5

type errno_policy = [ `Ignore_errno | `Return_errno ]

module Generate_C = struct
  let report_unpassable what =
    let msg = Printf.sprintf "cstubs does not support passing %s" what in
    raise (Unsupported msg)

  let local name ty = `Local (name, Ty ty)

  let rec ( >>= ) : type a. ccomp * a typ -> (cexp -> ccomp) -> ccomp =
   fun (e, ty) k ->
    let x = fresh_var () in
    match e with
    (* let x = v in e ~> e[x:=v] *)
    | #cexp as v -> k v
    | #ceff as e -> `Let ((local x ty, e), k (local x ty))
    | `CAMLparam (xs, c) ->
        let (Ty t) = Type_C.ccomp c in
        `CAMLparam (xs, (c, t) >>= k)
    | `LetConst (y, i, c) ->
        (* let x = (let const y = i in c) in e
           ~>
           let const y = i in (let x = c in e) *)
        let (Ty t) = Type_C.ccomp c in
        `LetConst (y, i, (c, t) >>= k)
    | `CAMLreturnT (Ty ty, v) ->
        (k v, ty) >>= fun e -> `CAMLreturnT (Type_C.cexp e, e)
    | `Return (Ty ty, v) -> (k v, ty) >>= fun e -> `Return (Type_C.cexp e, e)
    | `Let (ye, c) ->
        (* let x = (let y = e1 in e2) in e3
           ~>
           let y = e1 in (let x = e2 in e3) *)
        let (Ty t) = Type_C.ccomp c in
        `Let (ye, (c, t) >>= k)
    | `LetAssign (lv, v, c) ->
        (* let x = (y := e1; e2) in e3
           ~>
           y := e1; let x = e2 in e3 *)
        let (Ty t) = Type_C.ccomp c in
        `LetAssign (lv, v, (c, t) >>= k)

  let ( >> ) c1 c2 = (c1, Void) >>= fun _ -> c2

  let of_fatptr : cexp -> ceff =
   fun x ->
    `App (reader "CTYPES_ADDR_OF_FATPTR" (value @-> returning (ptr void)), [ x ])

  let pair_with_errno : cexp -> ceff =
   fun x ->
    `App (conser "ctypes_pair_with_errno" (value @-> returning value), [ x ])

  let string_to_ptr : cexp -> ccomp =
   fun x ->
    `App
      ( reader "CTYPES_PTR_OF_OCAML_STRING" (value @-> returning (ptr void)),
        [ x ] )

  let bytes_to_ptr : cexp -> ccomp =
   fun x ->
    `App
      ( reader "CTYPES_PTR_OF_OCAML_BYTES" (value @-> returning (ptr void)),
        [ x ] )

  let float_array_to_ptr : cexp -> ccomp =
   fun x ->
    `App
      ( reader "CTYPES_PTR_OF_FLOAT_ARRAY" (value @-> returning (ptr void)),
        [ x ] )

  let from_ptr : cexp -> ceff =
   fun x -> `App (conser "CTYPES_FROM_PTR" (ptr void @-> returning value), [ x ])

  let acquire_runtime_system : ccomp =
    `App (conser "caml_acquire_runtime_system" (void @-> returning void), [])

  let release_runtime_system : ccomp =
    `App (conser "caml_release_runtime_system" (void @-> returning void), [])

  let val_unit : ceff =
    `Global { name = "Val_unit"; references_ocaml_heap = true; typ = Ty value }

  let errno =
    `Global { name = "errno"; references_ocaml_heap = false; typ = Ty sint }

  let functions : ceff =
    `Global
      { name = "functions"; references_ocaml_heap = true; typ = Ty (ptr value) }

  let caml_callbackN : cfunction =
    {
      fname = "caml_callbackN";
      allocates = true;
      reads_ocaml_heap = true;
      fn = Fn (value @-> int @-> ptr value @-> returning value);
    }

  let copy_bytes : cfunction =
    {
      fname = "ctypes_copy_bytes";
      allocates = true;
      reads_ocaml_heap = true;
      fn = Fn (ptr void @-> size_t @-> returning value);
    }

  let cast : from:ty -> into:ty -> ccomp -> ccomp =
   fun ~from:(Ty from) ~into e -> (e, from) >>= fun x -> `Cast (into, x)

  let rec prj : type a b. a typ -> orig:b typ -> cexp -> ccomp option =
   fun ty ~orig x ->
    match ty with
    | Void -> None
    | Primitive p ->
        let ({ fn = Fn fn; _ } as prj) = prim_prj p in
        let rt = return_type fn in
        Some (cast ~from:rt ~into:(Ty (Primitive p)) (`App (prj, [ x ])))
    | Pointer _ -> Some (of_fatptr x :> ccomp)
    | Funptr _ -> Some (of_fatptr x :> ccomp)
    | Struct _s ->
        Some
          ( ((of_fatptr x :> ccomp), ptr void) >>= fun y ->
            `Deref (`Cast (Ty (ptr orig), y)) )
    | Union _u ->
        Some
          ( ((of_fatptr x :> ccomp), ptr void) >>= fun y ->
            `Deref (`Cast (Ty (ptr orig), y)) )
    | Abstract _ -> report_unpassable "values of abstract type"
    | View { ty; _ } -> prj ty ~orig x
    | Array _ -> report_unpassable "arrays"
    | Bigarray _ -> report_unpassable "bigarrays"
    | OCaml String -> Some (string_to_ptr x)
    | OCaml Bytes -> Some (bytes_to_ptr x)
    | OCaml FloatArray -> Some (float_array_to_ptr x)

  let prj ty x = prj ty ~orig:ty x

  let rec inj : type a. a typ -> clocal -> ceff =
   fun ty x ->
    match ty with
    | Void -> val_unit
    | Primitive p -> `App (prim_inj p, [ `Cast (Ty (Primitive p), (x :> cexp)) ])
    | Pointer _ -> from_ptr (x :> cexp)
    | Funptr _ -> from_ptr (x :> cexp)
    | Struct _s ->
        `App
          ( copy_bytes,
            [ `Addr (x :> cvar); `Int (Signed.SInt.of_int (sizeof ty)) ] )
    | Union _u ->
        `App
          ( copy_bytes,
            [ `Addr (x :> cvar); `Int (Signed.SInt.of_int (sizeof ty)) ] )
    | Abstract _ -> report_unpassable "values of abstract type"
    | View { ty; _ } -> inj ty x
    | Array _ -> report_unpassable "arrays"
    | Bigarray _ -> report_unpassable "bigarrays"
    | OCaml _ -> report_unpassable "ocaml references as return values"

  type _ fn =
    | Returns : 'a typ -> 'a fn
    | Function : string * 'a typ * 'b fn -> ('a -> 'b) fn
    | Buffers : 'a cbuffers -> 'a fn

  let rec name_params : type a. a Ctypes_static.fn -> a fn = function
    | Ctypes_static.Returns t -> Returns t
    | Ctypes_static.Function (f, t) -> Function (fresh_var (), f, name_params t)
    | Ctypes_static.Buffers b -> Buffers b
  (* 型変数aを変えることができないのでここではBuffer bのまま *)

  let rec value_params : type a. a fn -> (string * ty) list = function
    | Returns _t -> []
    | Function (x, _, t) -> (x, Ty value) :: value_params t
    | Buffers _b -> []

  let fundec : type a. string -> a Ctypes.fn -> cfundec =
   fun name fn -> `Fundec (name, args fn, return_type fn)

  let fn :
      type a.
      errno:errno_policy ->
      cname:string ->
      stub_name:string ->
      a Ctypes_static.fn ->
      cfundef =
   fun ~errno:errno_ ~cname ~stub_name f ->
    let fvar =
      { fname = cname; allocates = false; reads_ocaml_heap = false; fn = Fn f }
    in
    let rec body : type a. _ -> a fn -> _ =
     fun vars -> function
      | Returns t -> (
          let x = fresh_var () in
          let e = `App (fvar, (List.rev vars :> cexp list)) in
          match errno_ with
          | `Ignore_errno -> `Let ((local x t, e), (inj t (local x t) :> ccomp))
          | `Return_errno ->
              (`LetAssign
                 ( errno,
                   `Int Signed.SInt.zero,
                   `Let
                     ( (local x t, e),
                       ((inj t (local x t) :> ccomp), value) >>= fun v ->
                       (pair_with_errno v :> ccomp) ) )
                : ccomp))
      | Function (x, f, t) -> (
          match prj f (local x value) with
          | None -> body vars t
          | Some projected -> (projected, f) >>= fun x' -> body (x' :: vars) t)
      | Buffers (LastBuf (_, t)) ->
          body vars (Function ("hoge", t, Returns int))
      | _ -> raise (Unsupported "not implemented!(Cbuf_generate_c.fn)")
    in
    let f' = name_params f in
    let vp = value_params f' in
    `Function (`Fundec (stub_name, vp, Ty value), body [] f', `Extern)

  let byte_fn : type a. string -> a Ctypes_static.fn -> int -> cfundef =
   fun fname fn nargs ->
    let argv = ("argv", Ty (ptr value)) in
    let argc = ("argc", Ty int) in
    let f = { fname; allocates = true; reads_ocaml_heap = true; fn = Fn fn } in
    let rec build_call ?(args = []) = function
      | 0 -> `App (f, args)
      | n ->
          (`Index (`Local argv, `Int (Signed.SInt.of_int (n - 1))), value)
          >>= fun x -> build_call ~args:(x :: args) (n - 1)
    in
    let bytename = Printf.sprintf "%s_byte%d" fname nargs in
    `Function
      (`Fundec (bytename, [ argv; argc ], Ty value), build_call nargs, `Extern)

  let inverse_fn ~stub_name ~runtime_lock f =
    let (`Fundec (_, args, Ty rtyp) as dec) = fundec stub_name f in
    let idx = local (Printf.sprintf "fn_%s" stub_name) int in
    let project typ e =
      match prj typ e with None -> (e :> ccomp) | Some e -> e
    in
    let wrap_if cond (lft : ccomp) (rgt : ccomp) =
      if cond then lft >> rgt else rgt
    in
    let call =
      (* f := functions[fn_name];
         x := caml_callbackN(f, nargs, locals);
         y := T_val(x);
         CAMLdrop;
         y *)
      (`Index (functions, idx), value) >>= fun f ->
      ( `App
          (caml_callbackN, [ f; local "nargs" int; local "locals" (ptr value) ]),
        value )
      >>= fun x ->
      (project rtyp x, rtyp) >>= fun y ->
      (`CAMLdrop, void) >>= fun _ ->
      wrap_if runtime_lock release_runtime_system (`Return (Ty rtyp, y))
    in
    let body =
      (* locals[0] = Val_T0(x0);
         locals[1] = Val_T1(x1);
         ...
         locals[n] = Val_Tn(xn);
         call; *)
      snd
        (ListLabels.fold_right args
           ~init:(List.length args - 1, call)
           ~f:(fun (x, Ty t) (i, c) ->
             ( i - 1,
               `LetAssign
                 ( `Index
                     (local "locals" (ptr value), `Int (Signed.SInt.of_int i)),
                   inj t (local x t),
                   c ) )))
    in
    (* T f(T0 x0, T1 x1, ..., Tn xn) {
          enum { nargs = n };
          CAMLparam0();
          CAMLlocalN(locals, nargs);
          body
       } *)
    `Function
      ( dec,
        `LetConst
          ( local "nargs" int,
            `Int (Signed.SInt.of_int (List.length args)),
            wrap_if runtime_lock acquire_runtime_system
              (`CAMLparam0
              >> `CAMLlocalN
                   ( local "locals" (array (List.length args) value),
                     local "nargs" int )
              >> body) ),
        `Extern )

  let value :
      type a. cname:string -> stub_name:string -> a Ctypes_static.typ -> cfundef
      =
   fun ~cname ~stub_name typ ->
    let e, ty =
      ( `Addr
          (`Global
            { name = cname; typ = Ty typ; references_ocaml_heap = false }),
        ptr typ )
    in
    let x = fresh_var () in
    `Function
      ( `Fundec (stub_name, [ ("_", Ty value) ], Ty value),
        `Let ((local x ty, e), (inj (ptr typ) (local x ty) :> ccomp)),
        `Extern )
end

(* cname: バインドするCの関数名
   stub_name: スタブの関数名
   fn: 'a fn
*)
let fn ~errno ~cname ~stub_name fmt fn =
  let (`Function (`Fundec (f, xs, _), _, _) as dec) =
    Generate_C.fn ~errno ~stub_name ~cname fn
  in
  let nargs = List.length xs in
  if nargs > max_byte_args then (
    Cbuf_emit_c.cfundef fmt dec;
    Cbuf_emit_c.cfundef fmt (Generate_C.byte_fn f fn nargs))
  else Cbuf_emit_c.cfundef fmt dec

let value ~cname ~stub_name fmt typ =
  let dec = Generate_C.value ~cname ~stub_name typ in
  Cbuf_emit_c.cfundef fmt dec

let inverse_fn ~stub_name ~runtime_lock fmt fn : unit =
  Cbuf_emit_c.cfundef fmt (Generate_C.inverse_fn ~stub_name ~runtime_lock fn)

let inverse_fn_decl ~stub_name fmt fn =
  Format.fprintf fmt "@[%a@];@\n" Cbuf_emit_c.cfundec
    (Generate_C.fundec stub_name fn)
