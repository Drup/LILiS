%{
open Ls_type

let separate_args = Str.split (Str.regexp "[ \t]*,[ \t]*")

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
    NOM ARGS EQUAL expr	{ { left_mem = $1 ; var = separate_args $2 ; right_mem = $4 } }
  | NOM EQUAL expr      { { left_mem = $1 ; var = [] ; right_mem = $3 } }

expr:
    ordre expr { $1 :: $2 }
  | ordre      { [ $1 ] }

axiom: 
    LACCO expr RACCO { List.map (fun (name,l) -> (name,List.map (fun f -> f Env.empty) l) ) $2 }

ordre:
    NOM ARIT { ($1, List.map Mini_calc.closure (separate_args $2)) }
  | NOM      { ($1,[]) }

