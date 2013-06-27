
let lsystem_from_chanel chanel =
	let lexbuf = Lexing.from_channel chanel in
	Ls_parser.main Ls_lexer.token lexbuf
	;;
	
let lsystem_from_string s =
	let lexbuf = Lexing.from_string s in
	Ls_parser.main Ls_lexer.token lexbuf
	;;


