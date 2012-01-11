open Crayon;;
open Type;;
open BatEnum;;

(** Création et manipulation d'une liste d'ordre graphique *)

(** Apply a graphic_order *)
let draw turtle = function
	  TurnRight x ->	turtle#turn (-.x)
	| TurnLeft x ->		turtle#turn x
	| Forward x ->		turtle#move x
	| Backward x ->		turtle#move (-. x)
	| Trace ->			turtle#set_trace true
	| NoTrace ->		turtle#set_trace false
	| Save ->			turtle#save_position ()
	| Resume -> 		turtle#restore_position ()


(** Draw a graphic_order list
@param turtle : Turtle object wich will draw the order list
@param graphic_list : list of graphic_order
@result return the number of element in the graphic_list
*)
let draw_list turtle graphic_list =
	let f acc a = (draw turtle a ; acc + 1) in
	List.fold_left f 0 graphic_list

(** Extract the first element of the argument list and replace it with a default value if the list is empty *)
let get_value_arg l default = match l with
	  [] -> default
	| x::_ -> x

let draw_enum turtle graphic_enum =
	let f  = function
		  ("+",l) -> let x = (get_value_arg l 90.) in turtle#turn (-.x)
		| ("-",l) -> let x = (get_value_arg l 90.) in turtle#turn x
		| ("F",l) -> let x = (get_value_arg l 1.) in turtle#move x ; turtle#draw ()
		| ("B",l) -> let x = (get_value_arg l 1.) in turtle#move (-. x) ; turtle#draw ()
		| ("[",_) -> turtle#save_position ()
		| ("]",_) -> turtle#restore_position () ; turtle#draw ()
		| ("f",l) -> let x = (get_value_arg l 1.) in turtle#set_trace false ; turtle#move x ; turtle#set_trace true ; turtle#draw ()
		| _ -> ()
	in BatEnum.iter f graphic_enum

(** Transform a BatEnum into a graphic_order list *)
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
