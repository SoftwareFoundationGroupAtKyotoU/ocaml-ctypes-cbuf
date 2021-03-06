(*
 * Copyright (c) 2013 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

open Ctypes_static

let max_field_alignment fields =
  List.fold_left
    (fun align (BoxedField {ftype; _}) -> max align (alignment ftype))
    0
    fields

let max_field_size fields =
  List.fold_left
    (fun size (BoxedField {ftype; _}) -> max size (sizeof ftype))
    0
    fields

let aligned_offset offset alignment =
  match offset mod alignment with
    0 -> offset
  | overhang -> offset - overhang + alignment

let rec field : type t a. t typ -> string -> a typ -> (a, t) field =
  fun structured label ftype ->
  match structured with
  | Struct ({ spec = Incomplete spec; _ } as s) ->
    let foffset = aligned_offset spec.isize (alignment ftype) in
    let field = { ftype; foffset; fname = label } in
    begin
      spec.isize <- foffset + sizeof ftype;
      s.fields <- BoxedField field :: s.fields;
      field
    end
  | Union ({ uspec = None; _ } as u) ->
    let field = { ftype; foffset = 0; fname = label } in
    u.ufields <- BoxedField field :: u.ufields;
    field
  | Struct { tag; spec = Complete _; _ } -> raise (ModifyingSealedType tag)
  | Union { utag; _ } -> raise (ModifyingSealedType utag)
  | View { ty; _ } ->
     let { ftype; foffset; fname } = field ty label ftype in
     { ftype; foffset; fname }
  | _ -> raise (Unsupported "Adding a field to non-structured type")

let rec seal : type a. a typ -> unit = function
  | Struct { fields = []; _ } -> raise (Unsupported "struct with no fields")
  | Struct { spec = Complete _; tag; _ } -> raise (ModifyingSealedType tag)
  | Struct ({ spec = Incomplete { isize }; _ } as s) ->
    s.fields <- List.rev s.fields;
    let align = max_field_alignment s.fields in
    let size = aligned_offset isize align in
    s.spec <- Complete { (* sraw_io;  *)size; align }
  | Union { utag; uspec = Some _; _ } ->
    raise (ModifyingSealedType utag)
  | Union { ufields = []; _ } ->
    raise (Unsupported "union with no fields")
  | Union u -> begin
    u.ufields <- List.rev u.ufields;
    let size = max_field_size u.ufields
    and align = max_field_alignment u.ufields in
    u.uspec <- Some { align; size = aligned_offset size align }
  end
  | View { ty; _ } -> seal ty
  | _ -> raise (Unsupported "Sealing a non-structured type")
