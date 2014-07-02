(** Draw with {{: https://forge.ocamlcore.org/projects/cairo} cairo}. *)

(** A turtle that can draw on any Cairo surface. *)
val cairo_turtle : float -> float -> Cairo.context -> unit Glilis.turtle

(** A turtle that write to a png file. *)
val png_turtle : int -> int -> (string -> unit) Glilis.turtle

(** A turtle that write to a svg file. Buggy for now. *)
val svg_turtle : string -> int -> int -> unit Glilis.turtle

(** A turtle that write on a gtk surface. *)
val gtk_turtle : GMisc.drawing_area -> unit Glilis.turtle
