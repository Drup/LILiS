(** Graphical primitives for drawing L-systems. *)

(** We use a logo-like system to draw a L-system : a turtle is following the order in the Lstream. *)

type pos = { mutable x : float ; mutable y : float ; mutable d : float }

type color = { r : float ; g : float ; b : float ; a : float }

type orders = [
  | `Forward
  | `forward
  | `Turn
  | `Save
  | `Restore
  | `Color
]
(** The type of orders always accepted by a turtle. *)

val orders : (string * (orders * int)) list
(** Mapping from string tokens to orders. Also contains the arity of the orders. *)


class type ['a] turtle = object
  constraint 'a = [< orders ]

  method get_pos : pos
  (** Get the current position of the turtle. *)

  method get_color : color
  (** Get the current color of the turtle. *)

  method turn : float -> unit
  (** [turn a] turn the turtle by [a] degrees. *)

  method move : ?trace:bool -> float -> unit
  (** [move ~trace d] will move the turtle by [d] units.
      A line should be traced only if [trace] is true.
      It's up to the graphical implementation to respect this. *)

  method save_position : unit -> unit
  (** Save the position of the turtle in the stack. *)

  method restore_position : unit -> unit
  (** Restore the position of the turtle from the stack.
      @raise Empty_Stack if the stack is empty.*)

  method color : color -> unit

  method draw : 'a * float array -> unit
  (** Translate some usual symbol of L-system into a drawing order. *)

end
(** Class representing a turtle.
    This implementation doesn't draw anything but is doing all the movement calculations.
*)

class virtual ['a] vturtle :
  object
    constraint 'a = [< orders ]
    method get_pos : pos
    method get_color : color
    method turn : float -> unit
    method move : ?trace:bool -> float -> unit
    method save_position : unit -> unit
    method restore_position : unit -> unit
    method color : color -> unit
    method draw : 'a * float array -> unit
  end
(** This virtual turtle implements most movement calculations, without any actual drawing. See {! LisCairo} and {! LisTyxml} for use examples. See {! turtle} for methods documentation. *)
