(** Library to Interpret Lindenmayer Systems. 

    @author Gabriel Radanne
*)

(** This library is available {{:https://github.com/Drup/LILiS} here}. *)

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

For exemple here is the Von Koch curve :
{[
Von_koch
\{ F(1) \}
\{
F(l) = F(l/3) -(60) F(l/3) +(120) F(l/3) -(60) F(l/3)
\}
]}

*)

(** {2 Lsystem evaluation library} *)

module type LSTREAM = sig
  type 'a t 
  val singleton : 'a -> 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
  val expand : ('a -> 'b t) -> 'a t -> 'b t
  val expand_map : ('a -> 'b t) -> ('b -> 'c) -> 'a t -> 'c t
  val iter : ('a -> unit) -> 'a t -> unit
  val fold : ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b
  val of_list : 'a list -> 'a t
  val to_list : 'a t -> 'a list
  val clone : 'a t -> 'a t
  val force : 'a t -> unit
end 

module Lstream : LSTREAM

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
