(** Utilies for Lilis such as parsing and verification on lsystems. *)

module SMap : Map.S with type key = string

(** {2 Parsing} *)

exception OptionalArgument of ( string * string )
(** [ OptionalArgument (symbol, arg) ] *)

exception ParseError of (int * int * string)
(** [ParseError (line, col, token)] *)

val string_of_ParseError : (int * int * string) -> string
(** Output "Parse error on line %line, colunm %col, token %token" *)

val from_chanel : in_channel -> string Lilis.lsystem list
(** @raise ParseError foo *)

val from_string : string -> string Lilis.lsystem list
(** @raise ParseError foo *)


(** {2 Verifications} *)

exception ArityError of ( string * int * int )
(** [ ArityError ( symbol, defined_arity, used_arity ) ] *)

exception VarDefError of ( string * string )
(** [ VarDefError ( symbol, undefined_variable ) ] *)

exception TokenDefError of string
(** [ TokenDefError (symbol) ] *)

val check_stream : int SMap.t -> (string * 'a list) list -> unit
(** Check a stream against an environment. This environment is a mapping name -> arity.
    @raise ArityError, VarDefError, TokenDefError *)

val check_rule : int SMap.t -> ?arit_env:Mini_calc.arit_env -> string Lilis.rule -> unit
(** As [ check_stream ] for a rule. Need also an arithmetic environment, will use {! Mini_calc.Env.usual } if none is provided.
    @raise ArityError, VarDefError, TokenDefError *)

val replace_defs : ('a * ('b * int)) list -> 'a Lilis.lsystem -> 'b Lilis.lsystem
