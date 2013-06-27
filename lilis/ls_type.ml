(** Contient les types des objets qui seront ensuite manipulés *)

module Env = BatMap.Make(BatString)

(** type des expressions arithmetiques *)
type arit_expr = float Env.t -> float

type rule = {
	left_mem : string ;
	var : string list ;
	right_mem : (string * (arit_expr list)) list ;
	}

(** type lsystem utilisé dans le parser *)
type lsystem = {
	name : string ;
	axiom : (string * (float list)) list ;
	rules : rule list
	}
