open LisCommon
open LisParser

let (@@) = BatPervasives.(@@)
let (|>) = BatPervasives.(|>)

module SMap = SMap

(** {2 Verifications} *)

(** We have to verity two sort of things :
  - Arity is consistent.
  - Every variables used in a rule is defined.
*)

exception ArityError of ( string * int * int ) (* tok, defined, used *)
exception VarDefError of ( string * string ) (* tok, var *)
exception TokenDefError of string (* tok *)
exception OptionalArgument of ( string * string ) (* tok, arg *)

let check_expr env arit_env vars tok e =
  let is_def token variable =
    if not (Mini_calc.Env.mem variable arit_env || List.mem variable vars) then
      raise (VarDefError ( token, variable ))
  in
  let l = Mini_calc.get_vars e in
  List.iter (is_def tok) l


let is_def_tok env token =
  if not (SMap.mem token env) then
    raise (TokenDefError token)

let check_arity env tok vars =
  let defined_arity = match SMap.Exceptionless.find tok env with
    | Some x -> x
    | None -> raise @@ TokenDefError tok
  in
  let arity = List.length vars in
  if defined_arity <> arity then
    raise (ArityError ( tok, defined_arity, arity ))

(** {3 The exposed checking functions.} *)

let check_gen_stream env vars check_inside axiom =
  List.iter
    (fun (t,l) ->
       is_def_tok env t ;
       check_arity env t l ;
       check_inside t l)
    axiom

let check_stream env axiom =
  check_gen_stream
    env []
    (fun _ _ -> ()) axiom

let check_rule env ?(arit_env=Mini_calc.Env.usual) r =
  is_def_tok env r.Lilis.lhs ;
  check_arity env r.Lilis.lhs r.Lilis.vars ;
  let check_inside t l =
    List.iter (check_expr env arit_env r.Lilis.vars t) l
  in
  check_gen_stream env r.Lilis.vars check_inside r.Lilis.rhs



(** {2 Default definitions} *)

let defaut_defs = "
def F(d?1) = Forward(d)
def f(d?1) = forward(d)
def +(x?90) = Turn(x)
def -(x?90) = Turn(- x)
def [ = Save
def ] = Restore
def color(r,g,b,a?1) = Color(r,g,b,a)
"

let add_defs new_def lsys =
  { lsys with AST.definitions = new_def @ lsys.AST.definitions }

let replace_in_post_rules env {Lilis. name ; axiom ; rules ; post_rules } =
  let replace_def (tok,vars) =
    let (tok',arity) = match BatList.Exceptionless.assoc tok env with
      | Some x -> x
      | None -> raise (TokenDefError tok)
    in
    let used_arity = List.length vars in
    if arity <> used_arity then raise (ArityError (tok, arity, used_arity)) ;
    (tok',vars)
  in
  let in_rule {Lilis. lhs ; vars ; rhs } =
    let rhs = List.map replace_def rhs in
    {Lilis. lhs ; vars ; rhs }
  in
  let post_rules =
    List.map in_rule post_rules in
  {Lilis. name ; axiom ; rules ; post_rules }



(** {2 Transformation from ast to lsystem representation} *)

(** Evaluate the axiom *)
let eval_expr l =
  let f (name,l) =
    let open Mini_calc in
    name, List.map (fun t -> eval_tree Env.empty t) l
  in List.map f l

let foldAccum f l zero =
  let f' y (x,t) = let (x',h) = f y x in (x',h::t) in
  BatList.fold_right f' l (zero,[])


(** Extract definitions *)
let definitions (dl : AST.def list)  =
  let distribute (l,e) = List.map (fun k -> (k,e)) l in
  let dl = List.map distribute dl |> BatList.concat in
  let aux ((lhs,vars),rhs) env =
    let env' = SMap.add lhs vars env in
    (env', ((lhs,List.map fst vars),rhs))
  in
  let env, r = foldAccum aux dl SMap.empty in
  env, List.map (fun ((lhs,vars),rhs) -> {AST. lhs ; vars ; rhs}) r

(** Fill optional arguments according to a definition. *)
let fill_args defs (tok,vars) =
  let def = match SMap.Exceptionless.find tok defs with
    | Some x -> x
    | None -> raise @@ TokenDefError tok
  in
  let get (var,opt) = match opt with
    | Some x -> x
    | None -> raise @@ OptionalArgument (tok,var)
  in
  let rec f ddef l = match ddef,l with
    | _::def, h::t -> h :: (f def t)
    | l, [] -> List.map get l
    | _ -> raise @@ ArityError (tok, List.length def, List.length vars)
  in (tok, f def vars)

let fill_axiom defs axiom =
  List.map (fill_args defs) axiom

let fill_rule defs {AST. lhs ; vars ; rhs } =
  let rhs = fill_axiom defs rhs in
  {Lilis. lhs ; vars ; rhs }

let rule {AST. lhs ; vars ; rhs } =
  {Lilis. lhs ; vars ; rhs }

let lsystem lsystem =
  let name = lsystem.AST.name in
  let env, post_rules = definitions lsystem.AST.definitions in
  let post_rules = List.map rule post_rules in
  let axiom = eval_expr @@ fill_axiom env lsystem.AST.axiom in
  let rules = List.map (fill_rule env) lsystem.AST.rules in
  let env = SMap.map List.length env in
  let () = check_stream env axiom in
  let () = List.iter (check_rule env) rules in
  {Lilis. name ; axiom ; rules ; post_rules }


(** {2 Parsing} *)

exception ParseError of (int * int * string)

let string_of_ParseError (line, cnum, tok) =
  Printf.sprintf "Parse error on line %i, colunm %i, token %s"
    line cnum tok

let default_defs =
  let lexbuf = Lexing.from_string defaut_defs in
  try LisParser.defs LisLexer.token lexbuf
  with _ -> assert false

let parse_lex lexbuf =
  try
    LisParser.main LisLexer.token lexbuf
  with _ ->
      let curr = lexbuf.Lexing.lex_curr_p in
      let line = curr.Lexing.pos_lnum in
      let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
      let tok = Lexing.lexeme lexbuf in
      raise @@ ParseError (line, cnum, tok)

(** {3 Exposed Parsing functions, with lsystem transformation} *)

let parse_convert lexbuf =
  List.map
    (fun x -> lsystem (add_defs default_defs x))
    (parse_lex lexbuf)

let from_channel channel =
  let lexbuf = Lexing.from_channel channel in
  parse_convert lexbuf

let from_string s =
  let lexbuf = Lexing.from_string s in
  parse_convert lexbuf
