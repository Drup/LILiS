open Crayon;;
open Type;;
open BatEnum;;

(** Création et manipulation d'une liste d'ordre graphique *)


(** Dessine un flot d'ordre graphique
@param ctx Contexte dans lequel la bibliotheque graphique dessine (une fenetre, une image, etc)
@param graphic_list La liste des ordres graphiques en cours de dessins
@result Retourne le nombre d'element dans la liste
*)
let draw turtle graphic_list = 
	let f acc a = match a with
		  TurnRight x ->	turtle#turn (-.x) ; acc + 1 
		| TurnLeft x ->		turtle#turn x ; acc + 1
		| Forward x ->		turtle#move x ; acc + 1
		| Backward x ->		turtle#move (-. x) ; acc + 1
		| Trace ->			turtle#set_trace true ; acc + 1
		| NoTrace ->		turtle#set_trace false ; acc + 1
		| Save ->			turtle#save_position () ; acc + 1
		| Resume -> 		turtle#restore_position () ; acc + 1
	in List.fold_left f 0 graphic_list


let get_value_arg l default = match l with
	  [] -> default
	| x::_ -> x

let lstream_to_graphiclist lstream = 
	let f = function
		  ("+",l) -> let x = (get_value_arg l 90.) in singleton (TurnRight x)
		| ("-",l) -> let x = (get_value_arg l 90.) in singleton (TurnLeft x)
		| ("F",l) -> let x = (get_value_arg l 1.) in singleton (Forward x)
		| ("B",l) -> let x = (get_value_arg l 1.) in singleton (Backward x)
		| ("[",_) -> singleton Save
		| ("]",_) -> singleton Resume
		| ("f",l) -> let x = (get_value_arg l 1.) in BatList.enum [ NoTrace ; Forward x ; Trace ]
		| _ -> empty ()
	in BatList.of_enum (concat (map f lstream))

