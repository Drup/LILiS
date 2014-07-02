(** Core's Sequence.

    Persistent. *)

include Lilis.S with type 'a t = 'a Core_kernel.Sequence.t
