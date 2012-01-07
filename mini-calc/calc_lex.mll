{
open Calc_type
open Calc_pars        (* The type token is defined in parser.mli *)
}
rule token = parse
	  [' ' '\t']     { token lexbuf }     (* skip blanks *)
	| [ '0'-'9' ]+('.'[ '0'-'9']*)? as x	{FLOAT (float_of_string x)}
	| [ 'A'-'Z' 'a'-'z' ]+ as s	
		{ if List.mem_assoc s func_list 
			then FUNC (String.lowercase s)
			else IDENT (String.lowercase s) 
		} 
	| [ '\n' ] { EOL }
	| '+'	{ PLUS }
	| '-'	{ MINUS }
	| '*'	{ TIMES }
	| '/'	{ DIV }
	| '^'	{ POW }
	| '('	{ LPAREN }
	| ')'	{ RPAREN }
	| eof	{ EOL }
