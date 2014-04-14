(** Streams implementations from {{:http://batteries.forge.ocamlcore.org/}Batteries}. *)

module Stream : Lilis.S with type 'a t = 'a Stream.t
(** Stream from the standard library. Imperative. *)

module Seq : Lilis.S with type 'a t      = 'a BatSeq.t
                      and type 'a stored = 'a BatSeq.t
(** BatSeq from batteries. Functional. *)

module Gen : Lilis.S with type 'a t      = 'a BatGen.t
                       and type 'a stored = 'a BatGen.Restart.t
(** BatGen from batteries. Imperative. *)

module LazyList : Lilis.S with type 'a t      = 'a BatLazyList.t
                           and type 'a stored = 'a BatLazyList.t
(** Regular lazy list from batteries. Functional. *)
