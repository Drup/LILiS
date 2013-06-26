open Calc_type
open Calc_eval

(** Put together all other things *)

(** Parse a string containing an arithmetic expression to a tree *)
let string_to_tree s =
	let lexbuf = Lexing.from_string s in
	Calc_pars.main Calc_lex.token lexbuf
	;;

(** Print a tree, can be usefull sometimes .. *)
let rec tree_to_string t = match t with
    Float x -> Printf.sprintf "%f" x 
  | Op2 (t1,o,t2) -> 
      Printf.sprintf "( %s %s %s )" (tree_to_string t1) (op2_to_string o) (tree_to_string t2)
  | Op1 (o,t) -> 
      Printf.sprintf "( %s %s )" (op1_to_string o) (tree_to_string t)
  | Id s -> s

(** Eval an arithmetic expression in the given environment *)
let eval env s = 
  let t = (string_to_tree s) in 
  eval_tree (Env.fold Env.add env usual_env) t ;;

(** Return the closure of an arithmetic expression (and compress it in the usual env by the way*)
let closure s = let t = compress_tree usual_env (string_to_tree s) in (function env -> eval_tree env t)

(* Some Exemple *)
(*let s = read_line () in*)
(*print_endline s ;*)
(*print_float (eval [] s) ; print_newline() ;;*)

