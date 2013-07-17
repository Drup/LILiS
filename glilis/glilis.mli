(** Graphical primitives for drawing L-systems. *)

(** We use a logo-like system to draw a L-system : a turtle is following the order in the Lstream. *)

class turtle : object 

  method get_pos : unit -> float * float
  (** Get the curent [(x,y)] position of the turtle. *)

  method turn : float -> unit
  (** [turn a] turn the turtle by [a] degrees. *)

  method move : ?trace:bool -> float -> unit
  (** [move ~trace d] will move the turtle by [d] unit.
      A line should be traced only if [trace] is true.
      It's up to the graphical implementation to respect this. *)

  method save_position : unit -> unit
  (** Save the position of the turtle in the stack. *)

  method restore_position : unit -> unit
  (** Restore the position of the turtle from the stack.
      @raise Empty_Stack if the stack is empty.*)
end
(** Class representing a turtle. 
    This implementation doesn't draw anything but is doing all the movement calculations.
*)

val draw : #turtle -> string * float array -> unit
(** Translate some usual symbol of L-system into a drawing order. *)

val draw_enum : #turtle -> (string * float array) Lilis.Lstream.t -> unit

val draw_list : #turtle -> (string * float array) list -> unit