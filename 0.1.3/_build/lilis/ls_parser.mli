exception Error

type token = 
  | TIMES
  | RULE
  | RPAREN
  | RACCO
  | QMARK
  | POW
  | PLUS
  | NAME of (string)
  | MINUS
  | LPAREN
  | LACCO
  | IDENT of (string)
  | FUNC of (string)
  | FLOAT of (float)
  | EQUAL
  | EOF
  | END
  | DIV
  | DEF
  | COMMA
  | AXIOM


val main: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ls_type.AST.lsystem list)
val entry_arit: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (string Calc_type.arit_tree)
val defs: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ls_type.AST.def list)