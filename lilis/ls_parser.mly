%{
open Ls_type

let separate_args = Str.split (Str.regexp "[ \t]*,[ \t]*")

let eval_axiom l = 
  let f (name,l) = 
    let open Mini_calc in
    name, List.map (fun t -> eval_tree Env.empty t) l
  in List.map f l

%}

%token EOL EOF
%token <string> ARIT 
%token <string> ARGS
%token EQUAL
%token COMMA
%token <string> NOM
%token LACCO RACCO
%token LPAR RPAR
%start main
%type <Ls_type.lsystem list> main
%%

main:
    lsystem main { $1::$2 }
  | lsystem      { [$1] }

lsystem:
    NOM axiom setrules { {name = $1 ; axiom = $2 ; rules = $3} }

setrules :
    LACCO rules RACCO { $2 }

rules:
    rule EOL rules { $1::$3 }
  | rule           { [$1] }
	

rule: 
    NOM ARGS EQUAL expr	{ { lhs = $1 ; vars = separate_args $2 ; rhs = $4 } }
  | NOM EQUAL expr      { { lhs = $1 ; vars = [] ; rhs = $3 } }

expr:
    ordre expr { $1 :: $2 }
  | ordre      { [ $1 ] }

axiom: 
    LACCO expr RACCO   { eval_axiom $2 }

ordre:
    NOM ARIT { ($1, List.map Mini_calc.string_to_tree (separate_args $2)) }
  | NOM      { ($1,[]) }

