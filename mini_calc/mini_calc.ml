

include Calc_type
include Calc_eval

(** Put together all other things *)

(** Parse a string containing an arithmetic expression to a tree *)
let string_to_tree s =
	let lexbuf = Lexing.from_string s in
	Calc_parser.main Calc_lexer.token lexbuf
	;;


(** Eval an arithmetic expression in the given environment *)
let eval env s = 
  let t = (string_to_tree s) in 
  eval_tree (Env.union env Env.usual) t ;;

(** Return the closure of an arithmetic expression (and compress it in the usual env by the way*)
let closure s = let t = compress_tree Env.usual (string_to_tree s) in (function env -> eval_tree env t)
