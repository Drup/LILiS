{
open Ls_parser
}

let alpha = ['A'-'Z' 'a'-'z' '_' ]
let ws = [ ' ' '\t' ]

rule token = parse
	  '='	{ EQUAL }
	| [ '\n' ' ' '\t' ]* '{' [ '\n' ' ' '\t' ]*	{ LACCO }
	| [ '\n' ' ' '\t' ]* '}' [ '\n' ' ' '\t' ]*	{ RACCO }
	| '(' ws* ( ( ( alpha+ ws* ',' ws*)* alpha+ ) as s ) ws* ')'	{ ARGS s }
	| '(' ws* ( ( ( [^'(' ')']+ ws* ',' ws*)* [^'(' ')']+ ) as s ) ws* ')'	{ ARIT s }
	| ( alpha+ | '+' | '-' | '[' | ']' ) as s	{ NOM s}
	| eof	{ EOF }
	| [ '\n' ' ' '\t' ]* '\n' { EOL }
	| ws { token lexbuf }
