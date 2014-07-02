(** Core's Sequence. *)

include Core_kernel.Sequence
type 'a stored = 'a t
let map f x = map ~f x
let iter f l = iter ~f l
let fold f init l = fold ~f ~init l
let expand f x = concat_map ~f x
let store x = force_eagerly x
external gennew : 'a stored -> 'a t = "%identity"
