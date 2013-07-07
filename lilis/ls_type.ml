(** Various types for all other modules. *)

module Env = Mini_calc.Env

(** Stream of token with arguments. *)
module type LSTREAM = sig
  type 'a t 
  val singleton : 'a -> 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
  val expand : ('a -> 'b t) -> 'a t -> 'b t
  val expand_map : ('a -> 'b t) -> ('b -> 'c) -> 'a t -> 'c t
  val iter : ('a -> unit) -> 'a t -> unit
  val fold : ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b
  val of_list : 'a list -> 'a t
  val to_list : 'a t -> 'a list
  val clone : 'a t -> 'a t
  val force : 'a t -> unit
end 

module LsEnum = (struct
  include BatEnum
  let expand_map f g l = map g (concat (map f l))
  let expand f l = concat (map f l)
  let of_list = BatList.enum
  let to_list = BatList.of_enum
end : LSTREAM)

module Lstream = LsEnum

type lstream = (string * float list) Lstream.t

(** Arithmetic expressions. *)
type arit_expr = Mini_calc.arit_env -> float

(** A rule of rewriting *)
type rule = {
  lhs : string ;
  vars : string list ;
  rhs : (string * (arit_expr list)) list ;
}

(** A complete Lsystem. *)
type lsystem = {
  name : string ;
  axiom : (string * (float list)) list ;
  rules : rule list
}
