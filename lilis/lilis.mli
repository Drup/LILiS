(** Library to Interpret Lindenmayer Systems. *)

(** A L-system is described by a name, an axiom and a bunch of rules. Each symbols can have some arithmetic expressions as arguments.

An axiom is a list of symbols. A rule is composed of a left-hand side with a single symbol, potentially some variables and a right-hand side which is a list of symbols where arithmetic expressions can contains those variables.

Some symbols have a graphical meanings :
- [ F ] : Forward, takes a length as argument.
- [ B ] : Backward, takes a length as argument.
- [ f ] : forward without drawing.
- [ + ] : turn clockwise, takes an angle in degree as argument.
- [ - ] : turn counter-clockwise, takes an angle in degree as argument.
- [ \[ ] : save the current position on the stack.
- [ \] ] : restore the last saved position.

For example here is the Von Koch curve :
{v
Von_koch \{
axiom = F(1)
rules F(l) = F(l/3) -(60) F(l/3) +(120) F(l/3) -(60) F(l/3)
\}
v}

Indentation is optional. A rule must be terminated by a new line. You can't have a newline inside a succession of token (like a rule or an axiom).

*)

(** {2 Preliminary stream functions} *)

(**
   A stream-like data structure should be lazy and support O(1) concatenation.

   It should also be possible to store a datastructure in order to replicate it
   (to print it multiple time on screen, for example).

   For clonable data-structures, we can have {! S.t} identical to {! S.stored}
*)
module type S = LisTypes.S

(** {2 Lsystem representation} *)

type axiom = (string * (float list)) list
(** A simple Lsystem axiom. *)

type 'a rule = {
  lhs : string ;
  vars : string list ;
  rhs : ('a * (string Mini_calc.arit_tree list)) list ;
}
(** A Lsystem rule. *)

type 'a lsystem = {
  name : string ;
  axiom : axiom ;
  rules : string rule list ;
  post_rules : 'a rule list ;
}
(** A complete Lsystem. *)

(** {2 Input fonctions} *)

val lsystem_from_chanel : in_channel -> string lsystem list
val lsystem_from_string : string -> string lsystem list

(** {3 Utils} *)

module SMap : Map.S with type key = string

(** {3 Verifications} *)

exception ArityError of ( string * int * int )
(** [ ArityError ( symbol, defined_arity, used_arity ) ] *)

exception VarDefError of ( string * string )
(** [ VarDefError ( symbol, undefined_variable ) ] *)

exception TokenDefError of string
(** [ TokenDefError (symbol) ] *)

exception OptionalArgument of ( string * string )
(** [ OptionalArgument (symbol, arg) ] *)

val check_stream : int SMap.t -> (string * 'a list) list -> unit
(** Check a stream against an environment. This environment is a mapping name -> arity.
    @raise ArityError, VarDefError, TokenDefError *)

val check_rule : int SMap.t -> ?arit_env:Mini_calc.arit_env -> string rule -> unit
(** As [ check_stream ] for a rule. Need also an arithmetic environment, will use {! Mini_calc.Env.usual } if none is provided.
    @raise ArityError, VarDefError, TokenDefError *)

val replace_defs : ('a * ('b * int)) list -> 'a lsystem -> 'b lsystem

(** {3 Internal engine} *)

(** The symbolic environment is the dictionnary to compress and decompress streams. *)
module SymbEnv : sig
  type t
  (** A string <-> int mapping, used by the compression functions. *)

  val extract : axiom -> string rule list -> 'a rule list-> t
  (** Create a symbol environment from an axiom and a bunch of rules. *)

  val add_rule : t -> string rule -> t
  (** Add symbols from a rule to a symbolic environment. *)

  val add_post_rule : t -> 'a rule -> t
  (** Like [ add_rule ] but allow polymorphic rules. Ignore the right-hand side of the rule. *)

  val add_axiom : t -> axiom -> t
  (** Add symbols from an axiom to symbolic environment. *)

end

(**
   A functor to build your own little Lsystem engine given a stream-like data structure. Can be lazy or not, functional or not.

   The important operations from the performance point of view are [expand] and [map].
   Concatenation (as used in [expand]) must absolutely be in O(1) amortized time. Lazyness is better for memory occupation but is not necessary.

*)
module Engine (Lstream : S) : sig

  val eval_lsys :
    int -> 'a lsystem -> ('a * float array) Lstream.t
  (** Evaluate a Lsystem at the n-th generation. *)

  (** {2 Compression functions} *)

  (** A lsystem is first compressed before being iterated on.
      This compression allow far better performances.

      One of the step of compression is to transform string symbols into int.
      To be allowed to transform back and forth a lstream, the {! compress_lstream } function provide an environment from string symbols to int.
      This environment can be used by {! compress_lstream} and {! uncompress_lstream} for O(n) compression/uncompression. The lazyness of {! Lstream} is respected.
  *)

  type 'a lstream = ('a * float array) Lstream.t
  type 'a crules

  val compress_rules : SymbEnv.t -> string rule list -> int crules

  val compress_post_rules : SymbEnv.t -> 'a rule list -> 'a crules

  val compress_lslist : SymbEnv.t -> axiom -> (int * float array) Lstream.stored

  val compress_lstream : SymbEnv.t -> string lstream -> int lstream

  val uncompress_lstream : SymbEnv.t -> int lstream -> string lstream

  (** {2 Engine} *)

  val apply : ?n:int -> int crules -> int lstream -> int lstream
  (** [ apply rules lstream ] will apply rules once to [lstream]. The optional argument [n] can be used to apply more than once. *)

  val apply_complete : 'a crules -> int lstream -> 'a lstream
  (** As [ apply ] but with a complete maping. Symbols without rules are supressed. *)

  val eval_lsys_uncompress :
    int -> 'a lsystem -> (string * float array) Lstream.t
  (** Like [ eval_lsys ], but will ignore post rules and uncompress the stream instead. *)


end
