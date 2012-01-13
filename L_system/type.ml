(** Contient les types des objets qui seront ensuite manipules *)

(** type des expressions arithmetiques *)
type arit_expr = (string * float) list -> float

type rule = {
	left_mem : string ;
	var : string list ;
	right_mem : (string * (arit_expr list)) list ;
	}

(** type lsystem utilise dans le parser *)
type lsystem = {
	name : string ;
	axiom : (string * (float list)) list ;
	rules : rule list
	}
