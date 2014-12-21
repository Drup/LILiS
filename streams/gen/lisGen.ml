(** Gen, Imperative. *)
include Gen
type 'a stored = 'a Restart.t
let expand = flat_map
let of_list l = Restart.of_list l
let empty = Restart.empty
let store = persistent
let gennew = start
