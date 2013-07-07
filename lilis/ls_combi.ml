
type appl = string * string array
type rule = (appl * appl array)

type _ nonterm = 
  | Name : string -> appl nonterm
  | Arg : 'a nonterm -> (string -> 'a) nonterm

let to_fun t =
  let rec aux : type a . (string list) -> a nonterm -> a = 
    fun acc -> function
    | Arg t -> (fun arg -> aux (arg :: acc) t)
    | Name s -> s, Array.of_list (List.rev acc)
  in 
  aux [] t

let (!-) x = to_fun (Name x)
let (!+) x = to_fun (Arg (Name x))
let (!++) x = to_fun (Arg (Arg (Name x)))

let (-->) (lhs : appl) (rhs : appl list) : rule = 
  (lhs,rhs)

let f = !+ "f"
let turn = !+ "+"

let rule_f = f "l" --> [ f "l/2" ; turn "30" ]

(* let rule_f = rule f (fun l -> [ f (l/.2.) ; turn 30. ] *)
