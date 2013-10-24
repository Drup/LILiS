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
  [ ("sqrt",sqrt) ;
    ("sin",sin) ; ("cos",cos) ; ("tan",tan) ;
    ("log",log) ; ("log10",log10) ; ("exp",exp) ;
    ("asin",asin) ; ("acos",acos) ; ("atan",atan) ;
  ]

(** Type of tree which represent an arithmetic expression *)
type 'a arit_tree =
  | Float of float
  | Op2 of ('a arit_tree) * op2 * ('a arit_tree)
  | Op1 of op1 * ('a arit_tree)
  | Id of 'a

(** Print a tree, can be usefull sometimes .. *)
let rec tree_to_string t = match t with
    Float x -> Printf.sprintf "%f" x
  | Op2 (t1,o,t2) ->
      Printf.sprintf "( %s %s %s )" (tree_to_string t1) (op2_to_string o) (tree_to_string t2)
  | Op1 (o,t) ->
      Printf.sprintf "( %s %s )" (op1_to_string o) (tree_to_string t)
  | Id s -> s


exception Unknown_variable of string

(** The environment for variables *)
module Env = struct
  include BatMap.Make(BatString)

  let find_arit x env = match Exceptionless.find x env with
    | None -> raise (Unknown_variable x)
    | Some f -> f

  let union env1 env2 = fold add env1 env2

  let of_list = List.fold_left (fun env (k,x) -> add k x env) empty

  (** Define the usual env with some usefull constants *)
  let usual =
    of_list
      [ ("pi", 4. *. atan 1.) ;
	("e", exp 1.) ;
      ]
end

type arit_env = float Env.t
