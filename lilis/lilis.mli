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
Von_koch
axiom :
  F(1)
rules :
  F(l) = F(l/3) -(60) F(l/3) +(120) F(l/3) -(60) F(l/3)
end
v}

Indentation is optional. A rule must be terminated by a new line. You can't have a newline inside a succession of token (like a rule or an axiom).

*)

(** {2 Preliminary stream functions} *)

(** Encapsulate various stream-like data structures. *)
module Stream : sig

  module type S = sig
    type 'a t
    val singleton : 'a -> 'a t
    val map : ('a -> 'b) -> 'a t -> 'b t
    val expand : ('a -> 'b t) -> 'a t -> 'b t
    val iter : ('a -> unit) -> 'a t -> unit
    val fold : ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b
    val of_list : 'a list -> 'a t
    val to_list : 'a t -> 'a list
    val clone : 'a t -> 'a t
    val force : 'a t -> unit
  end

  module Seq : S with type 'a t = 'a BatSeq.t
  (** BatSeq from batteries. Functionnal (allow sharing). Fastest (for now ?). *)

  module Enum : S with type 'a t = 'a BatEnum.t
  (** BatEnum from batteries. Destructive reading, imperative. 2.5 time slower than Seq. *)

  module Stream : S with type 'a t = 'a Stream.t
(** Stream from the standard library. Use batteries for convenience. Destructive reading, imperative. ~10 time slower than Seq. Broken for now because lack of clone function.*)

  module LazyList : S with type 'a t = 'a BatLazyList.t
(** Regular lazy list from batteries. Functionnal. ~8 time slower than Seq. *)

end

module Lstream : Stream.S
(**
   The current best stream implementation, you can use this if you want a stable Stream module and don't care about the internals. Use BatSeq for now.
*)

(** {2 Lsystem evaluation library} *)

type lstream = (string * float array) Lstream.t
(** Stream of token with arguments. *)

type rule = {
  lhs : string ;
  vars : string list ;
  rhs : (string * (string Mini_calc.arit_tree list)) list ;
}
(** A Lsystem rule. *)

type lsystem = {
  name : string ;
  axiom : (string * (float list)) list ;
  rules : rule list
}
(** A complete Lsystem. *)

val lsystem_from_chanel : in_channel -> lsystem list
val lsystem_from_string : string -> lsystem list

val eval_lsys : int -> lsystem -> lstream
(** Evaluate a Lsystem at the n-th generation. *)

(** {3 Verifications} *)

type arityerror =
  { lsys : string ; symb : string ;
    defined_arity : int ; used_arity : int }
exception ArityError of arityerror

val check_arity : lsystem -> unit
(** Check arity of symbols across the given Lsystem.
    @raise ArityError if it's not. *)

type vardeferror =
  { lsys : string ; symb : string ;
    variable : string }

exception VarDefError of vardeferror

val check_vardef : lsystem -> Mini_calc.arit_env -> unit
(** Check if all arithmetic variables are correctly defined in the given Lsystem.
    @raise VarDefError if it's not. *)

(** {3 Internal engine} *)

module SMap : Map.S with type key = string

(**
   A functor to build your own little Lsystem engine given a stream-like data structure. Can be lazy or not, functional or not. 

   The important operations from the performance point of view are [expand] and [map].
   Concatenation (as used in [expand]) must absolutely be in O(1) amortized time. Lazyness is better for memory occupation but is not necessary.

*)
module Engine (Lstream : Stream.S) : sig

  val eval_lsys :
    int -> lsystem -> (string * float array) Lstream.t
  (** Evaluate a Lsystem at the n-th generation. *)

  (** {2 Compression functions} *)

  (** A lsystem is first compressed before being iterated on.
      This compression allow far better performances.

      One of the step of compression is to transform string symbols into int.
      To be allowed to transform back and forth a lstream, the {! compress_lstream } function provide an environment from string symbols to int. 
      This environment can be used by {! compress_lstream} and {! uncompress_lstream} for O(n) compression/uncompression. The lazyness of {! Lstream} is respected.
  *)

  type comp_lsystem

  val compress_lsys : lsystem -> int SMap.t * comp_lsystem

  val compress_lstream :
    int SMap.t -> (string * float array) Lstream.t -> (int * float array) Lstream.t

  val uncompress_lstream :
    int SMap.t -> (int * float array) Lstream.t -> (string * float array) Lstream.t

  (** {2 Engine} *)

  val apply :
    comp_lsystem -> ?n:int ->
    (int * float array) Lstream.t -> (int * float array) Lstream.t
  (** [ apply_again lsys lstream ] will apply [lsys]'s rules once to [lstream]. The optional argument [n] can be used to apply more than once. *)

  val eval_lsys_raw :
    int -> comp_lsystem -> (int * float array) Lstream.t
    (** Raw version of {! eval_lsys} that worked on compressed lsystem. *)


end
