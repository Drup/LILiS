(** CFStream library, a stream extension in core's style. *)

include CFStream.Stream
type 'a stored = 'a list
let map f l = map ~f l
let iter f l = iter ~f l
let fold f init l = fold ~f ~init l
let expand f x = concat_map x ~f
let of_list x = x
let store s = to_list s
let empty = []
let gennew l = CFStream.Stream.of_list l
