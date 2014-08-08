
(** Gen, Imperative. *)
module Gen = struct
  include CCGen
  type 'a stored = 'a Restart.t
  let expand = flat_map
  let of_list l = Restart.of_list l
  let empty = Restart.empty
  let store = persistent
  let gennew = start
end

(** CCKList, Persistent. *)
module KList = struct
  include CCKList
  type 'a stored = 'a t
  let expand = flat_map
  let empty = nil
  external store : 'a stored -> 'a t = "%identity"
  external gennew : 'a stored -> 'a t = "%identity"
end

(** CCSequence, Persistent. *)
module Sequence = struct
  include CCSequence
  type 'a stored = 'a t
  let expand = flatMap
  let store x = of_array (to_array x)
  external gennew : 'a stored -> 'a t = "%identity"
end
