(** Gen, from companion_cube's containers. *)

include Containers.Gen
type 'a stored = 'a Restart.t
let expand = flatMap
let of_list l = Restart.of_list l
let empty = Restart.empty
let store = persistent
let gennew = start
