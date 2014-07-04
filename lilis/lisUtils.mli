(** Utilities for Lilis such as parsing and verification on L-systems. *)

module SMap : Map.S with type key = string

(** {2 Parsing} *)

exception OptionalArgument of ( string * string )
(** [ OptionalArgument (symbol, arg) ] *)

exception ParseError of (int * int * string)
(** [ParseError (line, col, token)] *)

val string_of_ParseError : (int * int * string) -> string
(** Output "Parse error on line %line, colunm %col, token %token" *)

val from_channel : in_channel -> (string * string Calc.t list) Lilis.lsystem list
(** @raise ParseError on parse errors. *)

val from_string : string -> (string * string Calc.t list) Lilis.lsystem list
(** @raise ParseError on parse errors. *)

val lsystem_from_string : string -> (string * string Calc.t list) Lilis.lsystem
(** Parse only one lsystem.
    @raise ParseError on parse errors. *)

(** {2 Printing} *)

val to_string : (string * string Calc.t list) Lilis.lsystem -> string

val fprint : Format.formatter -> (string * string Calc.t list) Lilis.lsystem -> unit
val fprint_rule : Format.formatter -> (string * string Calc.t list) Lilis.rule -> unit


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

val check_rule :
  int SMap.t -> ?arit_env:Calc.Env.t -> (string * string Calc.t list)  Lilis.rule -> unit
(** As [ check_stream ] for a rule. Need also an arithmetic environment, will use {! Calc.Env.usual } if none is provided.
    @raise ArityError, VarDefError, TokenDefError *)

val replace_in_post_rules :
  (string * ('a * int)) list -> (string * 'b list) Lilis.lsystem -> ('a * 'b list) Lilis.lsystem
