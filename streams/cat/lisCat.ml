
module type S = sig
  type 'a t
  val empty : 'a t
  val singleton : 'a -> 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
  val iter : ('a -> unit) -> 'a t -> unit
  val fold : ('a -> 'b -> 'a) -> 'a -> 'b t -> 'a
  val flatmap : ('a -> 'b t) -> 'a t -> 'b t
  val of_list : 'a list -> 'a t
  val to_list : 'a t -> 'a list
end

module Cat (L : S) = struct

  type 'a t = Node of 'a t L.t | Val of 'a L.t


  let empty = Val L.empty
  let singleton x = Val (L.singleton x)

  let of_l l = Val l
  let of_list l = Val (L.of_list l)

  let concat_l x = Node x

  let rec concat = function
    | Val x -> Node x
    | Node l -> Node (L.map concat l)

  let map f t =
    let rec map_aux = function
      | Val x -> Val (L.map f x)
      | Node l -> Node (L.map map_aux l)
    in map_aux t

  let expand f t =
    let rec expand_aux = function
    | Val x -> Node (L.map f x)
    | Node l -> Node (L.map expand_aux l)
    in
    expand_aux t

  let rec fold f z t =
    let rec fold_aux z = function
      | Val x -> L.fold f z x
      | Node l -> L.fold fold_aux z l
    in
    fold_aux z t

  let iter f t =
    let rec iter_aux = function
      | Val x -> L.iter f x
      | Node l -> L.iter iter_aux l
    in
    iter_aux t

  let rec to_l = function
    | Val x -> x
    | Node l -> L.flatmap to_l l
  let to_list l = L.to_list @@ to_l l

  let flatten t =
    let rec flatten_aux = function
      | Val _ as t -> L.singleton t
      | Node l -> L.flatmap flatten_aux l
    in
    match t with
      | Val x -> t
      | Node l -> Node (L.flatmap flatten_aux l)


  type 'a stored = 'a t
  let gennew x = x
  let store x = x

end

module MyList = struct
  include BatList
  let to_list x = x
  let of_list x = x
  let fold = fold_left
  let empty = []
  let flatmap f x = List.concat (List.map f x)
end
module List = Cat(MyList)

module MySequence = struct
  include Sequence
  let flatmap = flatMap
end
module Sequence = Cat(MySequence)
