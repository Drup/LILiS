(** Graphical primitives for drawing L-systems. *)

(** We use a logo-like system to draw a L-system : a turtle is following the order in the Lstream. *)

type pos = { mutable x : float ; mutable y : float ; mutable d : float }

type color = { r : float ; g : float ; b : float ; a : float }

type orders =
  | Forward
  | Forward'
  | Turn
  | Save
  | Restore
  | Color

(** The type of orders always accepted by a turtle. *)

val orders : (string * (orders * int)) list
(** Mapping from string tokens to orders. Also contains the arity of the orders. *)

type 'a turtle = {
  get_pos : unit -> pos ;
  (** Get the curent position of the turtle. *)

  get_color : unit -> color ;
  (** Get the curent color of the turtle. *)

  turn : float -> unit ;
  (** [turn a] turn the turtle by [a] degrees. *)

  move : ?trace:bool -> float -> unit ;
  (** [move ~trace d] will move the turtle by [d] unit.
      A line should be traced only if [trace] is true.
      It's up to the graphical implementation to respect this. *)

  save_position : unit -> unit ;
  (** Save the position of the turtle in the stack. *)

  restore_position : unit -> unit ;
  (** Restore the position of the turtle from the stack.
      @raise Empty_Stack if the stack is empty.*)

  color : color -> unit ;
  (** Apply a color for the next drawings. *)

  handle_lsys : (unit -> unit) -> 'a
  (** Take a function with drawing side effects, handle the bureaucracy before executing it.*)

}
(** Class representing a turtle. *)

val turtle : unit -> unit turtle
(** This turtle implements most movement calculations, without any actual drawing. See {! LisCairo} and {! LisTyxml} for use examples. See {! turtle} for methods documentation. *)

val transform_rhs :
  'a turtle -> string -> ('c -> float) array -> 'c -> unit
(** Can be combined with {! Lilis.Engine.map_crules } to use {! Lilis.Engine.eval_iter_lsys }. *)

val transform_lsys :
  'a turtle -> (string * 'b) Lilis.lsystem ->
  (('c -> float) array -> 'c -> unit) Lilis.lsystem
(** Can be feeded directly to {! Lilis.Engine.eval_iter_lsys }. *)
