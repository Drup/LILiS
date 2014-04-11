(** Utilies for Lilis such as parsing and verification on L-systems. *)

module SMap : Map.S with type key = string

(** {2 Parsing} *)

exception OptionalArgument of ( string * string )
(** [ OptionalArgument (symbol, arg) ] *)

exception ParseError of (int * int * string)
(** [ParseError (line, col, token)] *)

val string_of_ParseError : (int * int * string) -> string
(** Output "Parse error on line %line, colunm %col, token %token" *)

val from_channel : in_channel -> string Lilis.lsystem list
(** @raise ParseError on parse errors. *)

val from_string : string -> string Lilis.lsystem list
(** @raise ParseError on parse errors. *)

(** {2 Printing} *)

val to_string : string Lilis.lsystem -> string
val rule_to_string : string Lilis.rule -> string


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

val check_rule : int SMap.t -> ?arit_env:Mini_calc.Env.t -> string Lilis.rule -> unit
(** As [ check_stream ] for a rule. Need also an arithmetic environment, will use {! Mini_calc.Env.usual } if none is provided.
    @raise ArityError, VarDefError, TokenDefError *)

val replace_in_post_rules : (string * ('b * int)) list -> string Lilis.lsystem -> 'b Lilis.lsystem
