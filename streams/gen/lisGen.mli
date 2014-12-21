(** Gen, Imperative. *)
include Lilis.S
  with type 'a t      = 'a Gen.t
   and type 'a stored = 'a Gen.Restart.t
