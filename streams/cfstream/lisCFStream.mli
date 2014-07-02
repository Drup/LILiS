(** {{:https://github.com/biocaml/cfstream}CFStream} library, a stream extension in core's style.

    Imperative, as Stream. *)

include Lilis.S with type 'a t = 'a Stream.t
