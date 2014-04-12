(** Input/Output utilities for arithmetic expressions. *)

val to_string : string Calc.t -> string
(** Print an arithmetic expressions. *)

val of_string : string -> string Calc.t
(** Parse an arithmetic expression. *)
