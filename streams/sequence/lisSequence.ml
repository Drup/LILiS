(** Sequence, from companion_cube. *)

include Sequence
type 'a stored = 'a t
let expand = flatMap
let store x = of_array (to_array x)
external gennew : 'a stored -> 'a t = "%identity"
