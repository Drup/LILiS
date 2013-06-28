(** Various types for all other modules. *)

module Env = Mini_calc.Env

(** Stream of token with arguments. *)
type lstream = (string * float list) BatEnum.t

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
