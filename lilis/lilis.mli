(** Library to Interpret Lindenmayer Systems. *)

(** {2 Lsystem evaluation library} *)

type arit_expr = Mini_calc.arit_env -> float
(** Arithmetic expressions used as arguments in rules. *)

type lstream = (string * float list) BatEnum.t
(** Stream of token with arguments. *)

type rule = {
  lhs : string;
  vars : string list;
  rhs : (string * arit_expr list) list;
}
(** A Lsystem rule. *)

type lsystem = {
  name : string;
  axiom : (string * float list) list;
  rules : rule list;
}
(** A complete Lsystem. *)

val lsystem_from_chanel : in_channel -> lsystem list
val lsystem_from_string : string -> lsystem list

val eval_lsys : int -> lsystem -> lstream
(** Evaluate a Lsystem at the n-th generation. *)


(** {2 Internal functions } *)

val get_rule : string -> Ls_type.rule list -> Ls_type.rule option
(** Get the rule that match the given symbol. *)

val eval_stream :
  Mini_calc.arit_env -> (string * arit_expr list) BatEnum.t -> lstream
(** Evaluate a stream of arit_expr. *)

val exec_rule : rule -> float list -> lstream
(** Apply a rule to some given arguments. *)

val get_transformation : lsystem -> string -> float list -> lstream
(** Get the transformation function from a Lsystem. *)

val generate_lstream : int -> lstream -> (string -> float list -> lstream) -> lstream
(** Generate a lstream at the n-th generation, with the given axiom and the given transformation function. *)

