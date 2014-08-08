open LisCommon
open LisParser

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
    if not (Calc.Env.mem variable arit_env || List.mem variable vars) then
      raise (VarDefError ( token, variable ))
  in
  Calc.vars e (is_def tok)


let is_def_tok env token =
  if not (SMap.mem token env) then
    raise (TokenDefError token)

let check_arity env tok vars =
  let defined_arity = try
      SMap.find tok env
    with Not_found -> raise @@ TokenDefError tok
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

let check_rule env ?(arit_env=Calc.Env.usual) r =
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
    let (tok',arity) = try
        List.assoc tok env
      with Not_found -> raise @@ TokenDefError tok
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



(** {2 Transformation from ast to L-system representation} *)

(** Extract definitions *)
let definitions (dl : AST.def list)  =
  let distribute (l,e) = List.map (fun k -> (k,e)) l in
  let dl = CCList.flat_map distribute dl in
  let aux ((lhs,vars),rhs) env =
    let env' = SMap.add lhs vars env in
    (env', ((lhs,List.map fst vars),rhs))
  in
  let env, r = foldAccum aux dl SMap.empty in
  env, List.map (fun ((lhs,vars),rhs) -> {AST. lhs ; vars ; rhs}) r

(** Fill optional arguments according to a definition. *)
let fill_args defs (tok,vars) =
  let def = try
      SMap.find tok defs
    with Not_found -> raise @@ TokenDefError tok
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
  let axiom = fill_axiom env lsystem.AST.axiom in
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

let parse_lex f lexbuf =
  try
    f LisLexer.token lexbuf
  with _ ->
      let curr = lexbuf.Lexing.lex_curr_p in
      let line = curr.Lexing.pos_lnum in
      let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
      let tok = Lexing.lexeme lexbuf in
      raise @@ ParseError (line, cnum, tok)

(** {3 Exposed Parsing functions, with L-system transformation} *)

let parse_convert lexbuf =
  List.map
    (fun x -> lsystem (add_defs default_defs x))
    (parse_lex LisParser.main lexbuf)

let lsystem_from_string s =
  Lexing.from_string s
  |> parse_lex LisParser.lsystem
  |> add_defs default_defs
  |> lsystem

let from_channel channel =
  parse_convert @@ Lexing.from_channel channel

let from_string s =
  parse_convert @@ Lexing.from_string s


(** {2 Printing} *)

(** Copied from ocaml 4.02 *)
let rec pp_print_list ?(pp_sep = Format.pp_print_cut) pp_v ppf = function
  | [] -> ()
  | [v] -> pp_v ppf v
  | v :: vs ->
    pp_v ppf v;
    pp_sep ppf ();
    pp_print_list ~pp_sep pp_v ppf vs

let fprint_tok f pp (symb,vars) =
  Format.fprintf pp "%s(%a)"
    symb
    (pp_print_list
       ~pp_sep:(fun pp () -> Format.fprintf pp ", ")
       (fun pp x -> Format.pp_print_string pp (f x)))
    vars

let fprint_stream f =
  pp_print_list
    ~pp_sep:(fun pp () -> Format.fprintf pp "@ ")
    (fprint_tok f)

let fprint_rule pp {Lilis. lhs ; vars ; rhs } =
  Format.fprintf pp "%a =@[<hov 2>@ %a@]"
    (fprint_tok CalcUtils.to_string) (lhs, List.map (fun x -> Calc.Var x) vars)
    (fprint_stream CalcUtils.to_string) rhs

let fprint pp {Lilis. name ; axiom ; rules ; post_rules } =
  Format.fprintf pp
    "%s {@\n  @[<v>axiom =@[<hov 2>@ %a@]@,rules {@\n@[<v 2>  %a@,@]}@,post rules {@\n@[<v 2>  %a@,@]}@]@\n}@\n"
    name
    (fprint_stream CalcUtils.to_string)
    axiom

    (pp_print_list
       ~pp_sep:(fun pp () -> Format.fprintf pp "@;")
       fprint_rule)
    rules

    (pp_print_list
       ~pp_sep:(fun pp () -> Format.fprintf pp "@;")
       fprint_rule)
    post_rules

let to_string l =
  fprint Format.str_formatter l ;
  Format.flush_str_formatter ()
