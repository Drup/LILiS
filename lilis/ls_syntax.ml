open Ls_type

let parse_lex lexbuf =
  try
    Ls_parser.main Ls_lexer.token lexbuf
  with _ ->
      let curr = lexbuf.Lexing.lex_curr_p in
      let line = curr.Lexing.pos_lnum in
      let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
      let tok = Lexing.lexeme lexbuf in
      failwith (
        Printf.sprintf "Parse error on line %i, colunm %i, token %s"
          line cnum tok
      )

let parse_convert lexbuf =
  List.map Ls_utils.lsystem @@ parse_lex lexbuf

let lsystem_from_chanel chanel =
  let lexbuf = Lexing.from_channel chanel in
  parse_convert lexbuf

let lsystem_from_string s =
  let lexbuf = Lexing.from_string s in
  parse_convert lexbuf
