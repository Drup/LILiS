open Calc_type
open Calc_pars
open Calc_lex
open Calc_eval

(** Put together all other things *)

(** Parse a string containing an arithmetic expression to a tree *)
let string_to_tree s =
	let lexbuf = Lexing.from_string s in
	Calc_pars.main Calc_lex.token lexbuf
	;;

(** Print a tree, can be usefull sometimes .. *)
let rec print_tree t = match t with
	  Float x -> print_float x 
	| Op2 (t1,o,t2) -> print_op2 o ; print_string "( " ; print_tree t1 ; print_string ", " ; print_tree t2 ; print_string " )"
	| Op1 (o,t) -> print_op1 o ; print_string "( " ; print_tree t ; print_string " )"
	| Id s -> print_string s

(** Eval an arithmetic expression in the given environment *)
let eval env s = let t = (string_to_tree s) in eval_tree (env@usual_env) t ;;

(** Return the closure of an arithmetic expression (and compress it in the usual env by the way*)
let closure s = let t = compress_tree usual_env (string_to_tree s) in (function env -> eval_tree env t)

(* Some Exemple *)
(*let s = read_line () in*)
(*print_endline s ;*)
(*print_float (eval [] s) ; print_newline() ;;*)

