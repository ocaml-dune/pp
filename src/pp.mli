(** Pretty-printing. *)

(** A document that is not yet rendered. The argument is the type of tags in the
    document. For instance tags might be used for styles. *)
type +'tag t

(** {1 Basic combinators} *)

(** A pretty printer that prints nothing *)
val nop : 'tag t

(** [seq x y] prints [x] and then [y] *)
val seq : 'tag t -> 'tag t -> 'tag t

(** [concat ?sep l] prints elements in [l] separated by [sep]. [sep] defaults to
    [nop]. *)
val concat : ?sep:'tag t -> 'tag t list -> 'tag t

(** Convenience function for [List.map] followed by [concat]. *)
val concat_map : ?sep:'tag t -> 'a list -> f:('a -> 'tag t) -> 'tag t

(** Convenience function for [List.mapi] followed by [concat]. *)
val concat_mapi : ?sep:'tag t -> 'a list -> f:(int -> 'a -> 'tag t) -> 'tag t

(** An indivisible block of text. *)
val verbatim : string -> 'tag t

(** A single character. *)
val char : char -> 'tag t

(** Print a bunch of text. The line may be broken at any spaces in the text. *)
val text : string -> 'tag t

(** Same as [text] but take a format string as argument. *)
val textf : ('a, unit, string, 'tag t) format4 -> 'a

(** {1 Break hints} *)

(** [space] instructs the pretty-printing algorithm that the line may be broken
    at this point. If the algorithm decides not to break the line, a single
    space will be printed instead.

    So for instance [verbatim "x" ++ space ++ verbatim "y"] might produce "x y"
    or "x\n<indentation>y". *)
val space : 'tag t

(** [cut] instructs the pretty-printing algorithm that the line may be broken at
    this point. If the algorithm decides not to break the line, nothing is
    printed instead.

    So for instance [verbatim "x" ++ space ++ verbatim "y"] might produce "xy"
    or "x\n<indentation>y". *)
val cut : 'tag t

(** [break] is a generalisation of [space] and [cut]. It also instructs the
    pretty-printing algorithm that the line may be broken at this point. If it
    ends up being broken, [shift] will be added to the indentation level,
    otherwise [nspaces] spaces will be printed. [shift] can be negative, in
    which case the indentation will be reduced. *)
val break : nspaces:int -> shift:int -> 'tag t

(** [custom_break ~fits:(a, b, c) ~breaks:(x, y, z)] is a generalisation of
    [break]. It also instructs the pretty-printing algorithm that the line may
    be broken at this point. If it ends up being broken, [x] is printed, the
    line breaks, [y] will be added to the indentation level and [z] is printed,
    otherwise [a] will be printed, [b] spaces are printed and then [c] is
    printed. The indentation [y] can be negative, in which case the indentation
    will be reduced. *)
val custom_break :
  fits:string * int * string -> breaks:string * int * string -> 'tag t

(** Force a newline to be printed. Usage is discourage since it breaks printing
    with boxes. If you need to add breaks to your text, put your items into
    [box]es and [concat] with a separating [space] afterwhich wrapping it in a
    [vbox]. *)
val newline : 'tag t

(** {1 Boxes} *)

(** Boxes are the basic components to control the layout of the text. Break
    hints such as [space] and [cut] may cause the line to be broken, depending
    on the splitting rules. Whenever a line is split, the rest of the material
    printed in the box is indented with [indent].

    You can think of a box with indentation as something with this shape:

    {v
       ######################### <- first line
       <indent>#################
       <indent>#################
       <indent>#################
       <indent>#################
    v}

    And the top left corner of this shape is anchored where the box was
    declared. So for instance, the following document:

    {[
      Pp.verbatim "....." ++ Pp.box ~indent:2 (Pp.text "some long ... text")
    ]}

    would produce:

    {v
       .....some long ...
              text
    v} *)

(** Try to put as much as possible on each line. Additionally, a break hint
    always break the line if the breaking would reduce the indentation level
    inside the box ([break] with negative [shift] value). *)
val box : ?indent:int -> 'tag t -> 'tag t

(** Always break the line when encountering a break hint. *)
val vbox : ?indent:int -> 'tag t -> 'tag t

(** Print everything on one line, no matter what *)
val hbox : 'tag t -> 'tag t

(** If possible, print everything on one line. Otherwise, behave as a [vbox] *)
val hvbox : ?indent:int -> 'tag t -> 'tag t

(** Try to put as much as possible on each line. Basically the same as [box] but
    without the rule about breaks with negative [shift] value. *)
val hovbox : ?indent:int -> 'tag t -> 'tag t

(** {1 Tags} *)

(** Tags are arbitrary pieces of information attached to a document. They can be
    used to add styles to pretty-printed text, for instance to print to the
    terminal with colors. *)

(** [tag x t] Tag the material printed by [t] with [x] *)
val tag : 'tag -> 'tag t -> 'tag t

(** Convert tags in a documents *)
val map_tags : 'from_tag t -> f:('from_tag -> 'to_tag) -> 'to_tag t

(** Convert tags in a documents, possibly removing some tags. *)
val filter_map_tags :
  'from_tag t -> f:('from_tag -> 'to_tag option) -> 'to_tag t

(** {1 Convenience functions} *)

(** [enumerate l ~f] produces an enumeration of the form:

    {v
      - item1
      - item2
      - item3
      ...
    v} *)
val enumerate : 'a list -> f:('a -> 'tag t) -> 'tag t

(** [chain l ~f] is used to print a succession of items that follow each other.
    It produces an output of this form:

    {v
         item1
      -> item2
      -> item3
      ...
    v} *)
val chain : 'a list -> f:('a -> 'tag t) -> 'tag t

(** {1 Operators} *)

module O : sig
  (** Infix operators for [Pp.t] *)

  (** Same as [seq] *)
  val ( ++ ) : 'tag t -> 'tag t -> 'tag t
end

(** {1 Rendering} *)

(** Render a document to a classic formatter *)
val to_fmt : Format.formatter -> 'tag t -> unit

val to_fmt_with_tags :
     Format.formatter
  -> 'tag t
  -> tag_handler:(Format.formatter -> 'tag -> 'tag t -> unit)
  -> unit

(** {1 Injection} *)

(** Inject a classic formatter in a document.

    Disclaimer: this function is to meant to help using [Pp] in existing code
    that already use the [Format] module without having to port everything to
    [Pp]. It is not meant as the normal way to create [Pp.t] values. *)
val of_fmt : (Format.formatter -> 'tag -> unit) -> 'tag -> 'tag t

(** {1 Ast} *)

module Ast : sig
  (** Stable representation useful for serialization *)
  type 'tag t =
    | Nop
    | Seq of 'tag t * 'tag t
    | Concat of 'tag t * 'tag t list
    | Box of int * 'tag t
    | Vbox of int * 'tag t
    | Hbox of 'tag t
    | Hvbox of int * 'tag t
    | Hovbox of int * 'tag t
    | Verbatim of string
    | Char of char
    | Break of (string * int * string) * (string * int * string)
    | Newline
    | Text of string
    | Tag of 'tag * 'tag t
end

(** [of_ast t] [Ast.t] to [Pp.t] *)
val of_ast : 'tag Ast.t -> 'tag t

(** [to_ast t] will try to convert [t] to [Ast.t]. When [t] contains values
    constructed with [of_fmt], this function will fail and return [Error ()] *)
val to_ast : 'tag t -> ('tag Ast.t, unit) result

(** {1 Comparison} *)

(** [compare cmp x y] compares [x] and [y] using [cmp] to compare tags.

    @raise Invalid_argument if two [of_fmt] values are compared. *)
val compare : ('tag -> 'tag -> int) -> 'tag t -> 'tag t -> int
