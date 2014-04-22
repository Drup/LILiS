(** Library to Interpret Lindenmayer Systems. *)

(** {2 L-system representation} *)

(** A L-system is described by a name, an axiom and a bunch of rules. Each symbols can have some arithmetic expressions as arguments. *)

type 'a stream = ('a * (float list)) list
(** A simple L-system axiom. An axiom is a list of symbols. *)

type 'a rule = {
  lhs : string ;
  vars : string list ;
  rhs : 'a list ;
}
(** A L-system rule. A rule is composed of a left-hand side with a single symbol, potentially some variables and a right-hand side which is a list of symbols where arithmetic expressions can contains those variables. The right hand side can be composed of non-string tokens. *)

type 'a lsystem = {
  name : string ;
  axiom : (string * string Calc.t list) list ;
  rules : (string  * string Calc.t list) rule list ;
  post_rules : 'a rule list ;
}
(** A complete L-system. ['a] is the output type of the L-system. For example, we can have a set of rules that will transform tokens to graphical orders. *)


(** {2 Functorized Engine} *)

(** The symbolic environment is the dictionary to compress and decompress streams. *)
module SymbEnv : sig
  type t
  (** A string <-> int mapping, used by the compression functions. *)

  val extract : string stream -> (string * 'b) rule list -> 'c rule list-> t
  (** Create a symbol environment from an axiom and a bunch of rules. *)

  val add_rule : t -> (string * 'a) rule -> t
  (** Add symbols from a rule to a symbolic environment. *)

  val add_post_rule : t -> 'a rule -> t
  (** Like [ add_rule ] but allow polymorphic rules. Ignore the right-hand side of the rule. *)

  val add_axiom : t -> string stream -> t
  (** Add symbols from an axiom to symbolic environment. *)

end


(**
   A stream-like data structure should be lazy and support O(1) concatenation.

   It should also be possible to store a datastructure in order to replicate it
   (to print it multiple time on screen, for example).

   For clonable data-structures, we can have {! S.t} identical to {! S.stored}
*)
module type S = sig
  type 'a t
  type 'a stored
  val singleton : 'a -> 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
  val expand : ('a -> 'b t) -> 'a t -> 'b t
  val iter : ('a -> unit) -> 'a t -> unit
  val fold : ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b
  val of_list : 'a list -> 'a stored
  val to_list : 'a t -> 'a list
  val force : 'a t -> unit
  val empty : 'a stored
  val store : 'a t -> 'a stored
  val gennew : 'a stored -> 'a t
end

(**
   A functor to build your own little L-system engine given a stream-like data structure. Can be lazy or not, functional or not.

   The important operations from the performance point of view are [expand] and [map].
   Concatenation (as used in [expand]) must absolutely be in O(1) amortized time. Laziness is better for memory occupation but is not necessary.

*)
module Make (Lstream : S) : sig

  val eval_lsys :
    int -> ('a * string Calc.t list) lsystem -> ('a * float array) Lstream.t
  (** Evaluate a L-system at the n-th generation. *)

  (** {2 Compression functions} *)

  (** A L-system is first compressed before being iterated on.
      This compression allows far better performances.

      One of the steps of compression is to transform string symbols into int.
      To be allowed to transform back and forth a lstream, the {! compress_lstream } function provides an environment from string symbols to int.
      This environment can be used by {! compress_lstream} and {! uncompress_lstream} for O(n) compression/uncompression. The laziness of {! Lstream} is respected.
  *)

  type 'a lstream = ('a * float array) Lstream.t
  type 'a crules

  val compress_rules :
    SymbEnv.t -> (string * string Calc.t list) rule list -> int crules

  val compress_post_rules :
    SymbEnv.t -> ('a * string Calc.t list) rule list -> 'a crules

  val compress_lslist : SymbEnv.t -> string stream -> (int * float array) Lstream.stored

  val compress_lsys : ('a * string Calc.t list) lsystem ->
SymbEnv.t * (int * float array) Lstream.stored *
int crules *
'a crules

  val compress_lstream : SymbEnv.t -> string lstream -> int lstream

  val uncompress_lstream : SymbEnv.t -> int lstream -> string lstream

  val map_crules : ('a -> 'b) -> 'a crules -> 'b crules

  (** {2 Engine} *)

  val apply : ?n:int -> int crules -> int lstream -> int lstream
  (** [ apply rules lstream ] will apply rules once to [lstream]. The optional argument [n] can be used to apply more than once. *)

  val apply_complete : 'a crules -> int lstream -> 'a lstream
  (** As [ apply ] but with a complete mapping. Symbols without rules are supressed. *)

  val eval_lsys_uncompress :
    int -> ('a * string Calc.t list) lsystem -> (string * float array) Lstream.t
  (** Like [ eval_lsys ], but will ignore post rules and uncompress the stream instead. *)

  (** {2 Not really safe} *)

  val iter_complete :
    ((float array -> float) array -> float array -> unit) crules -> int lstream -> unit
  (** Take a rule composed of unit functions and apply it to the stream. *)


  val eval_iter_lsys :
    int -> ('a * string Calc.t list) lsystem -> store:bool ->
    ('a -> (float array -> float) array -> float array -> unit) -> unit -> unit

  val eval_fold_lsys :
    int -> ('a * string Calc.t list) lsystem -> store:bool ->
    ('a -> (float array -> float) array -> 'b -> float array -> 'b) -> 'b -> 'b

end
