(** Draw to a svg using {{: http://ocsigen.org/tyxml/} tyxml}. *)

val svg_turtle : unit -> string Glilis.turtle
(** A turtle that draw to svg. It only creates a string containing an svg path. *)

val template : int * int -> string -> [> Svg_types.svg ] Svg.M.elt
(** [template size path] returns a complete svg elements using the path. *)
