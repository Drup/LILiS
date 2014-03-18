(** Various types for all other modules. *)

type axiom = (string * (float list)) list
(** A simple Lsystem axiom. *)

type 'a rule = {
  lhs : string ;
  vars : string list ;
  rhs : ('a * (string Mini_calc.arit_tree list)) list ;
}
(** A Lsystem rule. *)

type 'a lsystem = {
  name : string ;
  axiom : axiom ;
  rules : string rule list ;
  post_rules : 'a rule list ;
}
(** A complete Lsystem. *)

(**
   A stream-like data structure should be lazy and support O(1) concatenation.

   It should also be possible to store a datastructure in order to replicate it
   (to print it multiple time on screen, for example).

   For a clonable data-structure, we can have {! S.t} identical to {! S.stored}
*)
module type S = sig
  type 'a t
  type 'a stored
  val singleton : 'a -> 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
  val expand : ('a -> 'b t) -> 'a t -> 'b t
  val iter : ('a -> unit) -> 'a t -> unit
  val fold : ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b
  val of_list : 'a list -> 'a stored
  val to_list : 'a t -> 'a list
  val force : 'a t -> unit
  val empty : 'a stored
  val store : 'a t -> 'a stored
  val gennew : 'a stored -> 'a t
end

(** The AST for a Lsystem. *)
module AST : sig

  type arit = string Mini_calc.arit_tree

  type 'a token = string * 'a list

  type axiom = arit token list

  type expr = arit token list

  type def = ((string * arit option) token) list * expr

  type lsystem = {
    name : string ;
    definitions : def list ;
    axiom : axiom ;
    rules : string rule list ;
  }

  type env_def = ((string * arit option) token) list

end
