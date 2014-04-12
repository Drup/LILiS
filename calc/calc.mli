(** Small library to evaluate simple arithmetic expressions. *)

(**
   This library evaluates simple arithmetic expression over floats.
   Regular operators (+,-,*,/,^) and some regular functions (sin, cos, tan, asin, acos, atan, log, log10, exp, sqrt) are implemented.
   Arithmetic expressions can contain variables.

   Here is an example of expression : [ 3*x+sin(2) ].

*)

(** Type of binary operators *)
type op2 = Plus | Minus | Times | Div | Pow

(** Type of unary operators *)
type op1 = Func of (float -> float) | MinusUn ;;

(** Type of tree which represent an arithmetic expression *)
type 'a t =
  | Float of float
  | Op2 of ('a t) * op2 * ('a t)
  | Op1 of op1 * ('a t)
  | Var of 'a

module Env : sig
  type t
  val add : string -> float -> t -> t
  val mem : string -> t -> bool
  val union : t -> t -> t
  val of_list : (string * float) list -> t
  val empty : t
  val usual : t
end
(** Variable environment.

    {! Env.usual } contains [ pi ] and [ e ] .
*)

exception Unknown_variable of string

val eval : Env.t -> string t -> float
(** Evaluate a tree in the given environment.
    @raise Unkown_variable if a variable is not defined in the environment.
 *)

val compress : Env.t -> string t -> string t
(** Compress a tree in the given environment, ie. evaluate everything that can be evaluated. *)

(** {3 Some other functions} *)

val eval_custom : ('a -> float) -> 'a t -> float
(** Evaluate a tree, the given function is used to evaluate variables. *)

val compress_custom : ('a -> float option) -> 'a t -> 'a t
(** Compress a tree using the given function, ie. evaluate everything that can be evaluated.
    A variable is untouched if the function returns [ None ].
*)

val bind : ('a -> 'b t) -> 'a t -> 'b t
(** Replace each variables by a subtree. *)

val bind_opt : ('a -> 'a t option) -> 'a t -> 'a t
(** Replace some variables by a subtree. *)

val fold : ('a -> 'b -> 'b) -> 'a t -> 'b -> 'b
(** Depth first left to right traversal of the tree. *)

val map : ('a -> 'b) -> 'a t -> 'b t
(** Change variables representation using the given function. *)

val vars : 'a t -> 'a list
(** Get the list of variables in the given tree. *)

val closure :
  ?env:Env.t ->
  string t -> (string * 'a) list -> (('a -> float) -> float)
(** Compress the string in the optional env and return the resulting closure. *)
