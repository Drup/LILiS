(** Contient les types utiles ainsi que les opérateurs connus *)

(** Type of binary operator *)
type op_bin = Plus | Minus | Times | Div | Pow ;;

let print_op2 = function
	Plus -> print_string "+" | Minus -> print_string "-" | Times -> print_string "*" | Div -> print_string "/" | Pow -> print_string "^"

(** Type of unary operator *)
type op_un = Func of string | MinusUn ;;

let print_op1 = function Func s -> print_string s | MinusUn -> print_string "~-"

(** List of usual known function *)
let func_list = [ ("sin",sin) ; ("cos",cos) ; ("tan",tan) ; ("ln",log) ; ("exp",exp) ; ("sqrt",sqrt) ; ("atan",atan) ] ;;

(** Type of tree which represent an arithmetic expression *)
type arit_tree =
	  Float of float
	| Op2 of arit_tree * op_bin * arit_tree
	| Op1 of op_un * arit_tree
	| Id of string

