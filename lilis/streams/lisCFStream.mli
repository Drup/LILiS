(** CFStream library, a stream extension in core's style. *)

include Lilis.S with type 'a t = 'a Stream.t
