(** Various types for all other modules. *)

(** Arithmetic expressions. *)
type arit_expr = string Mini_calc.arit_tree

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
