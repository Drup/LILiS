

include Calc_type
include Calc_eval

(** Put together all other things *)

(** Parse a string containing an arithmetic expression to a tree *)
let string_to_tree s =
  let lexbuf = Lexing.from_string s in
  Calc_parser.entry_arit Calc_lexer.token lexbuf

(** Eval an arithmetic expression in the given environment *)
let eval env s = 
  let t = (string_to_tree s) in 
  eval_tree (Env.union env Env.usual) t ;;

(** Return the closure of a compressed arithmetic expression. *)
let closure ?(env=Env.empty) s vars = 
  let t = compress_tree (Env.union env Env.usual) (string_to_tree s) in
  let t = map_tree (fun x -> List.assoc x vars) t in
  (function env -> eval_tree_custom env t)
