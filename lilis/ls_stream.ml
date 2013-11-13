(** Describe various implementations of streams. *)

(* Convenient functions *)
let tap l () = l
external id : 'a -> 'a = "%identity"
external (|>) : 'a -> ('a -> 'b) -> 'b = "%revapply"

(** All structures are lazy and support O(1) concatenation. *)

(** Stream of token with arguments. *)
module type S = sig
  type 'a t
  type 'a stored
  val singleton : 'a -> 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
  val expand : ('a -> 'b t) -> 'a t -> 'b t
  val iter : ('a -> unit) -> 'a t -> unit
  val fold : ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b
  val of_list : 'a list -> 'a stored
  val to_list : 'a t -> 'a list
  val force : 'a t -> unit
  val empty : 'a stored
  val store : 'a t -> 'a stored
  val gennew : 'a stored -> 'a t
end

(** Seq from batteries. Functionnal (allow sharing). *)
module Seq = (struct
  include BatSeq
  type 'a stored = 'a t
  (* Modified version of BatSeq.concat in batteries *)
  let expand f s =
    let rec aux current rest () = match current () with
      | Cons(e, s) ->
          Cons(e, aux s rest)
      | Nil ->
          match rest () with
            | Cons(e, s) ->
                aux (f e) s ()
            | Nil ->
                Nil
    in
    aux nil s
  let fold = fold_left
  let force l = iter (fun x -> ()) l
  let of_list l = List.fold_right cons l nil
  let to_list l =
    fold_right (fun h t -> h :: t) l []
  let singleton x = cons x nil
  let empty = nil
  let store = id
  let gennew = id
end : S with type 'a t = 'a BatSeq.t and type 'a stored = 'a BatSeq.t)

(** Enum from batteries. Destructive reading, imperative. *)
module Enum = (struct
  include BatEnum
  type 'a stored = unit -> 'a t
  let expand f l = concat (map f l)
  let of_list l () = BatList.enum l
  let to_list = BatList.of_enum
  let store l () = clone l
  let gennew l = l ()
end : S with type 'a t = 'a BatEnum.t and type 'a stored = unit -> 'a BatEnum.t)

(** Regular lazy list from batteries. Functionnal. *)
module LazyList = (struct
  include BatLazyList
  type 'a stored = 'a t
  let expand f l = concat (map f l)
  let fold = fold_left
  let force l = iter (fun x -> ()) l
  let singleton x = cons x nil
  let empty = nil
  let of_list l = of_list l
  let store = id
  let gennew = id
end : S with type 'a t = 'a BatLazyList.t and type 'a stored = 'a BatLazyList.t)

(** Sequence, from companion_cube. *)
module Sequence = (struct
  include Sequence
  type 'a stored = 'a t
  let force l = iter (fun _ -> ()) l
  let expand = flatMap
  let store = id
  let gennew = id
end : S with type 'a t = 'a Sequence.t and type 'a stored = 'a Sequence.t)

(** Stream from the standard library. Use batteries for convenience. Destructive reading, imperative. *)
module Stream = (struct
  include BatStream
  type 'a stored = 'a list
  let expand f l = concat (map f l)
  let fold f z l = foldl (fun x y -> (f x y, None)) z l
  let force l = iter (fun x -> ()) l
  let of_list = id
  let singleton x = cons x (BatStream.of_list [])
  let store s = to_list s
  let empty = []
  let gennew l = BatStream.of_list l
end : S with type 'a t = 'a Stream.t )
