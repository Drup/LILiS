include Calc_type
include Calc_eval

(** Put together all other things *)

(** Parse a string containing an arithmetic expression to a tree *)
let of_string s =
  let lexbuf = Lexing.from_string s in
  Calc_parser.entry_arit Calc_lexer.token lexbuf

(** Eval an arithmetic expression in the given environment *)
let eval_string env s =
  let t = (of_string s) in
  eval (Env.union env Env.usual) t

(** Return the closure of a compressed arithmetic expression. *)
let closure ?(env=Env.empty) s vars =
  let t = compress (Env.union env Env.usual) (of_string s) in
  let t = map (fun x -> List.assoc x vars) t in
  (function env -> eval_custom env t)
