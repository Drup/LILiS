open Type ;;
open BatEnum ;;

let print_stream f stream = 
	iter (fun (s,l) -> 
		print_string (" " ^ s ^ " (") ; 
		List.iter (fun x -> f x; print_string " ") l ; 
		print_string ") " 
	) (clone stream)

(** Get the rule that match the given order *)
let rec get_rule ordre rules = match rules with
	  [] -> None (* No rule match the order *)
	| t::q when t.left_mem = ordre -> Some t (* Found the rule matching the order *)
	| _::q -> get_rule ordre q

(** Eval l_stream in the environement env *)
let eval_stream env l_stream = 
	let apply env f = f env in
	let f (ordre,ordre_args) = (ordre,List.map (apply env) ordre_args)
	in map f l_stream

(** Evalue les expressions arithmetiques d'une regle avec l'argument donne et renvoie un L_flux *)
let exec_rule arg rule = 
	let env = List.combine rule.var arg in eval_stream env (BatList.enum rule.right_mem)
	

(** Get the transformation function from a Lsystem *)
let get_transformation lsys =
	let transf ordre arg = match get_rule ordre lsys.rules with
		  None -> singleton (ordre,arg)
		| Some r -> exec_rule arg r
	in transf
	
(** Creation d'une courbe recursive de generation m, de premier element germe et de fonction transformation *) 
let courbe_recursive m germe transformation = 
	let developement lstream = 
		concat (map (function (ordre,args) -> transformation ordre args) lstream)
	in
	let rec generation n l = match n with
		  0 -> l
		| n -> generation (n-1) (developement l)
	in
	generation m germe
	
let eval_lsys n lsys = courbe_recursive n (BatList.enum lsys.axiom) (get_transformation lsys)
