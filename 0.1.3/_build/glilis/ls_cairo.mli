(** Draw with {{: https://forge.ocamlcore.org/projects/cairo} cairo}. *)

(** A turtle that can draw on any Cairo surface. *)
class ['a] cairo_turtle : float -> float -> Cairo.context ->
  object inherit ['a] Glilis.turtle

    (** Fill the picture with solid white and set the color to solid black *)
    method fill : unit -> unit

    (** Apply drawing on the surface *)
    method apply : unit -> unit

  end

(** A turtle that write to a png file. *)
class ['a] png_turtle : int -> int ->
  object inherit ['a] cairo_turtle
    (** Draw to a png *)
    method finish : string -> unit
  end

(** A turtle that write to a svg file. Buggy for now. *)
class ['a] svg_turtle : string -> int -> int ->
  object inherit ['a] cairo_turtle
    method finish : unit -> unit
  end

(** A turtle that write on a gtk surface. *)
class ['a] gtk_turtle : GMisc.drawing_area -> ['a] cairo_turtle
