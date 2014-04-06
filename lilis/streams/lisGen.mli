(** Gen, from companion_cube's containers. *)

include Lilis.S
    with type 'a t      = 'a Containers.Gen.t
     and type 'a stored = 'a Containers.Gen.Restart.t
