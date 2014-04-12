{
open Calc
open CalcParser        (* The type token is defined in parser.mli *)

let func_list = [
  ("sqrt",sqrt) ;
  ("sin",sin) ; ("cos",cos) ; ("tan",tan) ;
  ("log",log) ; ("log10",log10) ; ("exp",exp) ;
  ("asin",asin) ; ("acos",acos) ; ("atan",atan) ;
]
}
rule token = parse
    [' ' '\t']     { token lexbuf }     (* skip blanks *)
  | [ '0'-'9' ]+('.'[ '0'-'9']*)? as x	{FLOAT (float_of_string x)}
  | [ 'A'-'Z' 'a'-'z' ]+ as s
      { if List.mem_assoc s func_list
	then FUNC (List.assoc s func_list)
        else IDENT s
      }
  | [ '\n' ] { END }
  | '+'	{ PLUS }
  | '-'	{ MINUS }
  | '*'	{ TIMES }
  | '/'	{ DIV }
  | '^'	{ POW }
  | '('	{ LPAREN }
  | ')'	{ RPAREN }
  | eof	{ END }
