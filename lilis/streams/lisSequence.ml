(** Sequence, from companion_cube. *)

include Sequence
type 'a stored = 'a t
let force l = iter (fun _ -> ()) l
let expand = flatMap
let store x = force x ; x
external gennew : 'a stored -> 'a t = "%identity"
