(** Encapsulate various stream-like data structures. *)

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
