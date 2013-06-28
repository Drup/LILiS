(** Various types for all other modules. *)

module Env = Mini_calc.Env

(** Arithmetic expressions. *)
type arit_expr = Mini_calc.arit_env -> float

(** A rule of rewriting *)
type rule = {
  left_mem : string ;
  var : string list ;
  right_mem : (string * (arit_expr list)) list ;
}

(** A complete Lsystem. *)
type lsystem = {
  name : string ;
  axiom : (string * (float list)) list ;
  rules : rule list
}
