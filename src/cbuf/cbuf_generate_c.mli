(*
 * Copyright (c) 2014 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

(* C stub generation *)

val fn :
  errno:[ `Ignore_errno | `Return_errno ] ->
  cname:string ->
  stub_name:string ->
  Format.formatter ->
  'a Cbuf_static.fn ->
  unit

val value :
  cname:string -> stub_name:string -> Format.formatter -> 'a Ctypes.typ -> unit

val inverse_fn :
  stub_name:string ->
  runtime_lock:bool ->
  Format.formatter ->
  'a Cbuf_static.fn ->
  unit

val inverse_fn_decl :
  stub_name:string -> Format.formatter -> 'a Cbuf_static.fn -> unit
