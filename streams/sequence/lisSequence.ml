(** Sequence, Persistent. *)
include Sequence
type 'a stored = 'a t
let expand = flatMap
let store x = of_array (to_array x)
let gennew : 'a stored -> 'a t = fun x -> x
