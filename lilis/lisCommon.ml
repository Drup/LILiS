(** Various stuff for all other modules. *)

(** The AST for a Lsystem. *)
module AST = struct

  type arit = string Mini_calc.t

  type 'a token = string * 'a list

  type axiom = arit token list

  type expr = arit token list

  type def = ((string * arit option) token) list * expr

  type rule = {
    lhs : string ;
    vars : string list ;
    rhs : (string * (arit list)) list ;
  }

  type lsystem = {
    name : string ;
    definitions : def list ;
    axiom : axiom ;
    rules : rule list ;
  }

  type env_def = ((string * arit option) token) list

end

module SMap = BatMap.Make(BatString)
