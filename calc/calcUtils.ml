open Calc

let of_string s =
  let lexbuf = Lexing.from_string s in
  CalcParser.entry_arit CalcLexer.token lexbuf


let op2_to_string = function
  | Plus  -> "+"
  | Minus -> "-"
  | Times -> "*"
  | Div   -> "/"
  | Pow   -> "^"

let op1_to_string = function
  | Func s -> "<fun>"
  | MinusUn -> "~-"

let rec to_string t = match t with
    Float x -> Printf.sprintf "%f" x
  | Op2 (t1,o,t2) ->
      Printf.sprintf "( %s %s %s )" (to_string t1) (op2_to_string o) (to_string t2)
  | Op1 (o,t) ->
      Printf.sprintf "( %s %s )" (op1_to_string o) (to_string t)
  | Var s -> s
