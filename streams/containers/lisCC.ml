(** CCKList, Persistent. *)
module KList = struct
  include CCKList
  type 'a stored = 'a t
  let expand = flat_map
  let empty = nil
  let store : 'a stored -> 'a t = fun x -> x
  let gennew : 'a stored -> 'a t = fun x -> x
end
