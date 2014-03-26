(** {1 Input fonctions} *)

open LisTypes

exception ParseError of (int * int * string)
(** [ParseError (line, col, token)] *)

val string_of_ParseError : (int * int * string) -> string
(** Output "Parse error on line %line, colunm %col, token %token" *)

val lsystem_from_chanel : in_channel -> string lsystem list
(** @raise ParseError *)

val lsystem_from_string : string -> string lsystem list
(** @raise ParseError *)
