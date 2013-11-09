(** Various types for all other modules. *)

type arit = string Mini_calc.arit_tree

module SMap = BatMap.Make(BatString)

type axiom = (string * (float list)) list

(** A rule of rewriting *)
type rule = {
  lhs : string ;
  vars : string list ;
  rhs : (string * (arit list)) list ;
}

(** A complete Lsystem. *)
type lsystem = {
  name : string ;
  axiom : (string * (float list)) list ;
  rules : rule list ;
  post_rules : rule list ;
}

module AST = struct

  type 'a token = string * 'a list

  type axiom = arit token list

  type expr = arit token list

  type def = ((string * arit option) token) list * expr

  type lsystem = {
    name : string ;
    definitions : def list ;
    axiom : axiom ;
    rules : rule list ;
  }

  type env_def = ((string * arit option) token) list

end
