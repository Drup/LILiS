(** Describe various implementations of streams. *)

(** All structures are lazy and support O(1) concatenation. *)

(** Stream of token with arguments. *)
module type S = sig
  type 'a t
  val singleton : 'a -> 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
  val expand : ('a -> 'b t) -> 'a t -> 'b t
  val iter : ('a -> unit) -> 'a t -> unit
  val fold : ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b
  val of_list : 'a list -> 'a t
  val to_list : 'a t -> 'a list
  val clone : 'a t -> 'a t
  val force : 'a t -> unit
  val empty : unit -> 'a t
end

(** Seq from batteries. Functionnal (allow sharing). *)
module Seq = (struct
  include BatSeq
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
  let clone l = l
  let of_list l = List.fold_right cons l nil
  let to_list l =
    fold_right (fun h t -> h :: t) l []
  let singleton x = cons x nil
  let empty () = nil
end : S with type 'a t = 'a BatSeq.t  )

(** Enum from batteries. Destructive reading, imperative. *)
module Enum = (struct
  include BatEnum
  let expand f l = concat (map f l)
  let of_list l = BatList.enum l
  let to_list = BatList.of_enum
end : S with type 'a t = 'a BatEnum.t )

(** Regular lazy list from batteries. Functionnal. *)
module LazyList = (struct
  include BatLazyList
  let expand f l = concat (map f l)
  let fold = fold_left
  let force l = iter (fun x -> ()) l
  let clone l = l
  let singleton x = cons x nil
  let empty () = nil
end : S with type 'a t = 'a BatLazyList.t )

(** Sequence, from companion_cube. *)
module Sequence = (struct
  include Sequence
  let force l = iter (fun _ -> ()) l
  let expand = flatMap
  let empty () = empty
  let clone l = l
end : S with type 'a t = 'a Sequence.t)
