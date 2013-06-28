(** Small library to evaluate simple arithmetic expressions. 

    @author Gabriel Radanne
*)

(** 
   This library evaluates simple arithmetic expression over floats.
   Regular operators (+,-,*,/,^) and some regular functions (sin, cos, tan, asin, acos, atan, log, log10, exp, sqrt) are implemented.
   Arithmetic expressions can contains variables.
   
   Here is an example of expression : [ 3*x+sin(2) ].

   This library was designed to be used by {{:https://github.com/Drup/LILiS} LILiS}.

*)


type arit_tree 
  (** Type of arithmetic trees. *)

val tree_to_string : arit_tree -> string
  (** Print an arithmetic tree. *)

val string_to_tree : string -> arit_tree
  (** Parse an arithmetic expression. *)

type arit_env

module Env : sig
  val add : string -> float -> arit_env -> arit_env
  val union : arit_env -> arit_env -> arit_env
  val of_list : (string * float) list -> arit_env
  val empty : arit_env
  val usual : arit_env
end
(** Variable environment.
    
    [ Env.usual ] contains [ pi ] and [ e ] .
*)

exception Unknown_variable of string

val eval_tree : arit_env -> arit_tree -> float
(** Evaluate a tree in the given environment.
    @raise Unkown_variable if a variable is not define in the environment.
 *)
  
val eval : arit_env -> string -> float
(** Evaluate the arithmetic expression in the given environment and the usual environment.
    @raise Unkown_variable if a variable is not define in the environment.
 *)

val compress_tree : arit_env -> arit_tree -> arit_tree
(** Compress a tree in the given environment, ie. evaluate everything that can be evaluated. *)

val closure : string -> arit_env -> float
(** Compress the string in the usual environment and return the resulting closure. *)
