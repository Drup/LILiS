(** Sequence, from the sequence package, by companion_cube. *)

include LisStream.S
  with type 'a t = 'a Sequence.t
   and type 'a stored = 'a Sequence.t
