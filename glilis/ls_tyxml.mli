(** Draw to a svg using {{: http://ocsigen.org/tyxml/} tyxml}. *)

class ['a] svg_turtle :
  object inherit ['a] Glilis.turtle

    (** Export the path as a string. *)
    method to_string : unit -> string

  end
(** A turtle that draw to svg. It only creates a string containing an svg path. *)

val template : int * int -> string -> [> Svg_types.svg ] Svg.M.elt
(** [template size path] returns a complete svg elements using the path. *)
