(** Various stuff for all other modules. *)

(** The AST for a Lsystem. *)
module AST = struct

  type arit = string Calc.t

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

module SMap = Map.Make(String)

let foldAccum f l zero =
  let f' y (x,t) = let (x',h) = f y x in (x',h::t) in
  List.fold_right f' l (zero,[])

let wrap f =
  try Some (f ()) with _ -> None

let (@@-) f l = Sequence.(to_list @@ f @@ of_list l)

include CCFun
