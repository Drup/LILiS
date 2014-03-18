open LisTypes

let default_defs =
  let lexbuf = Lexing.from_string LisUtils.defaut_defs in
  try LisParser.defs LisLexer.token lexbuf
  with _ -> assert false

let parse_lex lexbuf =
  try
    LisParser.main LisLexer.token lexbuf
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
  List.map
    (fun x -> LisUtils.lsystem (LisUtils.add_defs default_defs x))
    (parse_lex lexbuf)

let lsystem_from_chanel chanel =
  let lexbuf = Lexing.from_channel chanel in
  parse_convert lexbuf

let lsystem_from_string s =
  let lexbuf = Lexing.from_string s in
  parse_convert lexbuf
