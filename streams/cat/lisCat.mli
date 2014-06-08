
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

module Cat (L : S) : sig
  type 'a t = Node of 'a t L.t | Val of 'a L.t
  include Lilis.S with type 'a t := 'a t
  val concat_l : 'a t L.t -> 'a t
  val of_l : 'a L.t -> 'a t
  val to_l : 'a t -> 'a L.t
  val flatten : 'a t -> 'a t
end

module MyList : S with type 'a t = 'a list
module List : module type of Cat(MyList)

module MySequence : S with type 'a t = 'a Sequence.t
module Sequence : module type of Cat(MySequence)
