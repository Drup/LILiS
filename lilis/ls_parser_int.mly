%{
open Ls_type

let eval_axiom l = 
  let f (name,l) = 
    let open Mini_calc in
    name, List.map (fun t -> eval_tree Env.empty t) l
  in List.map f l

%}

%token <string> NAME
%token COMMA
%token EQUAL
%token LACCO RACCO
%token AXIOM RULE

%start main
%type <Ls_type.lsystem list> main

%%

main:
  ls = nonempty_list(lsystem) END
  { ls }

lsystem:
  name=IDENT LACCO
  axiom=axiom
  rules=rule+
  RACCO
  { { name ; axiom=axiom ; rules } }

axiom:
  AXIOM EQUAL ol=order+ { eval_axiom ol }

rule:
  RULE n = ls_token v = loption(vars) EQUAL ol=order*
  { { lhs = n ; vars = v  ; rhs = ol } }

order:
  n = ls_token a = loption(args)
  { (n,a) }

vars:
  LPAREN v=separated_list(COMMA,IDENT) RPAREN
  { v }

args: 
  LPAREN a=separated_list(COMMA, arit) RPAREN 
  { a }

ls_token: 
  | n=NAME | n=IDENT { n }
  | PLUS  { "+" } | MINUS { "-" }
  | TIMES { "*" } | DIV   { "/" }
  | POW   { "^" }
