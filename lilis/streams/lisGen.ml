(** Gen, from companion_cube's containers. *)

include Containers.Gen
type 'a stored = 'a Restart.t
let force l = iter (fun _ -> ()) l
let expand = flatMap
let of_list l = Restart.of_list l
let store = persistent
let gennew = start
