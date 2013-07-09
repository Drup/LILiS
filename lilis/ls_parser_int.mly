%{
open Ls_type

let eval_axiom l = 
  let f (name,l) = 
    let open Mini_calc in
    name, List.map (fun t -> eval_tree Env.empty t) l
  in List.map f l

%}

%token EOL AXIOM RULES ENDLS
%token EQUAL
%token COMMA //RCOMMA
%token <string> NAME
%start main
%type <Ls_type.lsystem list> main

%%

main:
  ls = nonempty_list(lsystem) END
  { ls }

lsystem:
  name = IDENT EOL* axiom=axiom EOL* rules=rules ENDLS EOL*
  { {name ; axiom ; rules } }

axiom:
  AXIOM EOL* e=expr
  { eval_axiom e }

rules:
  RULES EOL* rules = list(rule)
  { rules }

rule: 
  n = ls_token v = loption(vars) EQUAL e = expr EOL+
  { { lhs = n ; vars = v  ; rhs = e } }


expr: 
  orders = nonempty_list(order)
  { orders }

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
