open Crayon;;
open BatEnum;;


(** Extract the first element of the argument list and replace it with a default value if the list is empty *)
let get_value_arg l default = match l with
	  [] -> default
	| x::_ -> x

(** translate some usual symbol of L-system into drawing order *)
let draw turtle graphic_enum =
	let f  = function
		  ("+",l) -> let x = (get_value_arg l 90.) in turtle#turn (-.x)
		| ("-",l) -> let x = (get_value_arg l 90.) in turtle#turn x
		| ("F",l) -> let x = (get_value_arg l 1.) in turtle#move x
		| ("B",l) -> let x = (get_value_arg l 1.) in turtle#move (-. x)
		| ("[",_) -> turtle#save_position ()
		| ("]",_) -> turtle#restore_position ()
		| ("f",l) -> let x = (get_value_arg l 1.) in turtle#set_trace false ; turtle#move x ; turtle#set_trace true
		| _ -> ()
	in BatEnum.iter f graphic_enum
