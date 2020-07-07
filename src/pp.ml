module List = struct
  include ListLabels

  let map ~f t = rev (rev_map ~f t)
end

module String = StringLabels

module Fit_or_break = struct
  type t = string * int * string

  let ( ^ ) a b =
    match (a, b) with
    | "", _ -> b
    | _, "" -> a
    | _ -> a ^ b

  let compose (a, b, c) (d, e, f) = (a ^ d, b + e, f ^ c)
end

module Break = struct
  type t =
    { fits : Fit_or_break.t
    ; breaks : Fit_or_break.t
    }

  let compose a b =
    { fits = Fit_or_break.compose a.fits b.fits
    ; breaks = Fit_or_break.compose a.breaks b.breaks
    }
end

type +'a t =
  | Nop
  | Seq of 'a t * 'a t
  | Concat of 'a t * 'a t list
  | Box of int * 'a t
  | Vbox of int * 'a t
  | Hbox of 'a t
  | Hvbox of int * 'a t
  | Hovbox of int * 'a t
  | Verbatim of string
  | Char of char
  | Break of Break.t
  | Extend_breaks of Break.t * 'a t
  | Newline
  | Tag of 'a * 'a t

let rec map_tags t ~f =
  match t with
  | Nop -> Nop
  | Seq (a, b) -> Seq (map_tags a ~f, map_tags b ~f)
  | Concat (sep, l) -> Concat (map_tags sep ~f, List.map l ~f:(map_tags ~f))
  | Box (indent, t) -> Box (indent, map_tags t ~f)
  | Vbox (indent, t) -> Vbox (indent, map_tags t ~f)
  | Hbox t -> Hbox (map_tags t ~f)
  | Hvbox (indent, t) -> Hvbox (indent, map_tags t ~f)
  | Hovbox (indent, t) -> Hovbox (indent, map_tags t ~f)
  | (Verbatim _ | Char _ | Break _ | Newline) as t -> t
  | Tag (tag, t) -> Tag (f tag, map_tags t ~f)
  | Extend_breaks (b, t) -> Extend_breaks (b, map_tags t ~f)

let rec filter_map_tags t ~f =
  match t with
  | Nop -> Nop
  | Seq (a, b) -> Seq (filter_map_tags a ~f, filter_map_tags b ~f)
  | Concat (sep, l) ->
    Concat (filter_map_tags sep ~f, List.map l ~f:(filter_map_tags ~f))
  | Box (indent, t) -> Box (indent, filter_map_tags t ~f)
  | Vbox (indent, t) -> Vbox (indent, filter_map_tags t ~f)
  | Hbox t -> Hbox (filter_map_tags t ~f)
  | Hvbox (indent, t) -> Hvbox (indent, filter_map_tags t ~f)
  | Hovbox (indent, t) -> Hovbox (indent, filter_map_tags t ~f)
  | (Verbatim _ | Char _ | Break _ | Newline) as t -> t
  | Tag (tag, t) -> (
    let t = filter_map_tags t ~f in
    match f tag with
    | None -> t
    | Some tag -> Tag (tag, t) )
  | Extend_breaks (b, t) -> Extend_breaks (b, filter_map_tags t ~f)

module Render = struct
  open Format

  let rec render break ppf t ~tag_handler =
    match t with
    | Nop -> ()
    | Seq (a, b) ->
      render break ppf ~tag_handler a;
      render break ppf ~tag_handler b
    | Concat (_, []) -> ()
    | Concat (sep, x :: l) ->
      render break ppf ~tag_handler x;
      List.iter l ~f:(fun x ->
          render break ppf ~tag_handler sep;
          render break ppf ~tag_handler x)
    | Box (indent, t) ->
      pp_open_box ppf indent;
      render break ppf ~tag_handler t;
      pp_close_box ppf ()
    | Vbox (indent, t) ->
      pp_open_vbox ppf indent;
      render break ppf ~tag_handler t;
      pp_close_box ppf ()
    | Hbox t ->
      pp_open_hbox ppf ();
      render break ppf ~tag_handler t;
      pp_close_box ppf ()
    | Hvbox (indent, t) ->
      pp_open_hvbox ppf indent;
      render break ppf ~tag_handler t;
      pp_close_box ppf ()
    | Hovbox (indent, t) ->
      pp_open_hovbox ppf indent;
      render break ppf ~tag_handler t;
      pp_close_box ppf ()
    | Verbatim x -> pp_print_string ppf x
    | Char x -> pp_print_char ppf x
    | Break break' ->
      let { Break.fits; breaks } =
        match break with
        | None -> break'
        | Some break -> Break.compose break break'
      in
      pp_print_custom_break ppf ~fits ~breaks
    | Extend_breaks (break', t) ->
      let break =
        Some
          ( match break with
          | None -> break'
          | Some break -> Break.compose break break' )
      in
      render break ppf t ~tag_handler
    | Newline -> pp_force_newline ppf ()
    | Tag (tag, t) ->
      let t =
        match break with
        | None -> t
        | Some break -> Extend_breaks (break, t)
      in
      tag_handler ppf tag t
end

let to_fmt_with_tags ppf t ~tag_handler = Render.render None ppf t ~tag_handler

let rec to_fmt ppf t =
  Render.render None ppf t ~tag_handler:(fun ppf _tag t -> to_fmt ppf t)

let nop = Nop

let seq a b =
  match (a, b) with
  | Nop, _ -> b
  | _, Nop -> a
  | _ -> Seq (a, b)

module O = struct
  let ( ++ ) = seq
end

open O

let concat ?(sep = Nop) = function
  | [] -> Nop
  | [ x ] -> x
  | l -> Concat (sep, l)

let concat_map ?(sep = Nop) l ~f =
  match l with
  | [] -> Nop
  | [ x ] -> f x
  | l -> Concat (sep, List.map l ~f)

let concat_mapi ?(sep = Nop) l ~f =
  match l with
  | [] -> Nop
  | [ x ] -> f 0 x
  | l -> Concat (sep, List.mapi l ~f)

let box ?(indent = 0) t = Box (indent, t)

let vbox ?(indent = 0) t = Vbox (indent, t)

let hbox t = Hbox t

let hvbox ?(indent = 0) t = Hvbox (indent, t)

let hovbox ?(indent = 0) t = Hovbox (indent, t)

let verbatim x = Verbatim x

let char x = Char x

let custom_break ~fits ~breaks = Break { fits; breaks }

let extend_breaks t ~fits ~breaks = Extend_breaks ({ fits; breaks }, t)

let break ~nspaces ~shift =
  custom_break ~fits:("", nspaces, "") ~breaks:("", shift, "")

let space = break ~nspaces:1 ~shift:0

let cut = break ~nspaces:0 ~shift:0

let newline = Newline

let text =
  let add_verbatim s i j acc =
    if i = j then
      acc
    else
      acc ++ Verbatim (String.sub s ~pos:i ~len:(j - i))
  in
  let rec loop s len i j acc =
    if j = len then
      add_verbatim s i j acc
    else
      match s.[j] with
      | ' ' ->
        let acc = add_verbatim s i j acc in
        loop s len (j + 1) (j + 1) (acc ++ space)
      | '\n' ->
        let acc = add_verbatim s i j acc in
        loop s len (j + 1) (j + 1) (acc ++ newline)
      | _ -> loop s len i (j + 1) acc
  in
  fun s -> loop s (String.length s) 0 0 nop

let textf fmt = Printf.ksprintf text fmt

let tag tag t = Tag (tag, t)

let enumerate l ~f =
  vbox
    (concat ~sep:cut
       (List.map l ~f:(fun x -> box ~indent:2 (seq (verbatim "- ") (f x)))))

let chain l ~f =
  vbox
    (concat ~sep:cut
       (List.mapi l ~f:(fun i x ->
            box ~indent:3
              (seq
                 (verbatim
                    ( if i = 0 then
                      "   "
                    else
                      "-> " ))
                 (f x)))))
