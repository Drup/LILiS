(** Gen, from {{:https://github.com/c-cube/ocaml-containers}companion_cube's containers}.

    Imperative. *)

include Lilis.S
    with type 'a t      = 'a Containers.Gen.t
     and type 'a stored = 'a Containers.Gen.Restart.t
