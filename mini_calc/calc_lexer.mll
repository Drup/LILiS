{
open Calc_type
open Calc_parser        (* The type token is defined in parser.mli *)
}
rule token = parse
    [' ' '\t']     { token lexbuf }     (* skip blanks *)
  | [ '0'-'9' ]+('.'[ '0'-'9']*)? as x	{FLOAT (float_of_string x)}
  | [ 'A'-'Z' 'a'-'z' ]+ as s	
      { if List.mem_assoc s func_list 
	then FUNC s
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
