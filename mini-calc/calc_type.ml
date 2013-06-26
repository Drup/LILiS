(** Contient les types utiles ainsi que les opérateurs connus *)

(** Type of binary operator *)
type op2 = Plus | Minus | Times | Div | Pow 

let op2_to_string = function
  | Plus  -> "+" 
  | Minus -> "-" 
  | Times -> "*" 
  | Div   -> "/" 
  | Pow   -> "^"

(** Type of unary operator *)
type op1 = Func of string | MinusUn ;;

let op1_to_string = function 
  | Func s -> s 
  | MinusUn -> "~-"

(** List of usual known function *)
let func_list = 
  [ ("sin",sin) ; ("cos",cos) ; ("tan",tan) ; 
    ("ln",log) ; ("exp",exp) ; ("sqrt",sqrt) ; 
    ("atan",atan) 
  ] 

(** Type of tree which represent an arithmetic expression *)
type arit_tree =
  | Float of float
  | Op2 of arit_tree * op2 * arit_tree
  | Op1 of op1 * arit_tree
  | Id of string

