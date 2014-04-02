(** Batteries streams implementations. *)

module Stream : Lilis.S with type 'a t = 'a Stream.t
(** Stream from the standard library. *)

module Seq : Lilis.S with type 'a t      = 'a BatSeq.t
                      and type 'a stored = 'a BatSeq.t
(** BatSeq from batteries. Functionnal (allow sharing). *)

module Enum : Lilis.S with type 'a t      = 'a BatEnum.t
(** BatEnum from batteries. Destructive reading, imperative. *)

module LazyList : Lilis.S with type 'a t      = 'a BatLazyList.t
                           and type 'a stored = 'a BatLazyList.t
(** Regular lazy list from batteries. Functionnal. *)