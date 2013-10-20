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
  let of_list l = Array.fold_right cons (Array.of_list l) nil
  let to_list l = BatList.of_enum (enum l)
  let singleton x = cons x nil
end : S with type 'a t = 'a BatSeq.t  )

(** Enum from batteries. Destructive reading, imperative. *)
module Enum = (struct
  include BatEnum
  let expand f l = concat (map f l)
  let of_list l = BatArray.enum (Array.of_list l)
  let to_list = BatList.of_enum
end : S with type 'a t = 'a BatEnum.t )

(** Stream from the standard library. Use batteries for convenience. Destructive reading, imperative. ~10 time slower than Seq. Broken for now because lack of clone function.*)
module Stream = (struct
  include BatStream
  let expand f l = concat (map f l)
  let fold f z l = foldl (fun x y -> (f x y, None)) z l
  let force l = iter (fun x -> ()) l
  let clone l = l (* Noooo *)
  let singleton x = cons x (of_list [])
end : S with type 'a t = 'a Stream.t )

(** Regular lazy list from batteries. Functionnal. *)
module LazyList = (struct
  include BatLazyList
  let expand f l = concat (map f l)
  let fold = fold_left
  let force l = iter (fun x -> ()) l
  let clone l = l
  let singleton x = cons x nil
  let of_list l =
    of_array (Array.of_list l)
end : S with type 'a t = 'a BatLazyList.t )

(** Sequence, from companion_cube. *)
module Sequence = (struct
  include Sequence
  let force l = iter (fun _ -> ()) l
  let expand = flatMap
  let clone l = l
  let of_list l =
    of_array (Array.of_list l)
end : S with type 'a t = 'a Sequence.t)
