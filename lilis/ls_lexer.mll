{
open Ls_parser

(* TOFIX I have to paste Calc_type.func_list here, this is bad. *)
let func_list = 
  [ ("sqrt",sqrt) ; 
    ("sin",sin) ; ("cos",cos) ; ("tan",tan) ; 
    ("log",log) ; ("log10",log10) ; ("exp",exp) ; 
    ("asin",asin) ; ("acos",acos) ; ("atan",atan) ; 
  ] 

}

let alpha = ['A'-'Z' 'a'-'z' '_' ]
let ls_name = [ 'A'-'Z' 'a'-'z' '_'  '+' '-' '[' ']' '@' '#' ]+
let ws = [ ' ' '\t' ]

rule token = parse
  | "axiom" ws* ":" { AXIOM }
  | "rules" ws* ":" { RULES }
  | "end" { ENDLS }
  | '='	{ EQUAL }
  | ','	{ COMMA }
(*  | ';'	{ RCOMMA } *)
  (* | '{' { LACCO } *)
  (* | '}' { RACCO } *)
(* TOFIX We have to paste part of calc_lexer.mll here, this is highly unsatisfying. *)
  | '+'	{ PLUS }
  | '-'	{ MINUS }
  | '*'	{ TIMES }
  | '/'	{ DIV }
  | '^'	{ POW }
  | '('	{ LPAREN }
  | ')'	{ RPAREN }
  | [ '0'-'9' ]+('.'[ '0'-'9']*)? as x	{FLOAT (float_of_string x)}
  | alpha+ as s	
      { if List.mem_assoc s func_list 
	then FUNC s
        else IDENT s
      } 
  | ls_name as s { NAME s}
  | eof	{ END }
  | ws { token lexbuf }
  | '\n' { Lexing.new_line lexbuf ; EOL }
