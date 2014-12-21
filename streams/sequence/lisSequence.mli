(** CCSequence, Persistent. also available in the standalone package sequence. *)
include Lilis.S
  with type 'a t      = 'a Sequence.t
   and type 'a stored = 'a Sequence.t
