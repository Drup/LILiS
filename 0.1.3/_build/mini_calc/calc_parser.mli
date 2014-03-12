exception Error

type token = 
  | TIMES
  | RPAREN
  | POW
  | PLUS
  | MINUS
  | LPAREN
  | IDENT of (string)
  | FUNC of (string)
  | FLOAT of (float)
  | END
  | DIV


val entry_arit: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (string Calc_type.arit_tree)