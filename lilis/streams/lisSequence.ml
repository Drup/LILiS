(** Sequence, from companion_cube. *)

include Sequence
type 'a stored = 'a t
let force l = iter (fun _ -> ()) l
let expand = flatMap
external store : 'a t -> 'a stored = "%identity"
external gennew : 'a stored -> 'a t = "%identity"
