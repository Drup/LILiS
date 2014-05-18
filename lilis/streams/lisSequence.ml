(** Sequence, from companion_cube. *)

include Sequence
type 'a stored = 'a t
let expand = flatMap
let store x = iter ignore x ; x
external gennew : 'a stored -> 'a t = "%identity"
