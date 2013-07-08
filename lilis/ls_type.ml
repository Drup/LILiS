(** Various types for all other modules. *)

(** Stream of token with arguments. *)
module type LSTREAM = sig
  type 'a t 
  val singleton : 'a -> 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
  val expand : ('a -> 'b t) -> 'a t -> 'b t
  val expand_map : ('a -> 'b t) -> ('b -> 'c) -> 'a t -> 'c t
  val iter : ('a -> unit) -> 'a t -> unit
  val fold : ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b
  val of_list : 'a list -> 'a t
  val to_list : 'a t -> 'a list
  val clone : 'a t -> 'a t
  val force : 'a t -> unit
end 

module LsEnum = (struct
  include BatEnum
  let expand_map f g l = map g (concat (map f l))
  let expand f l = concat (map f l)
  let of_list = BatList.enum
  let to_list = BatList.of_enum
end : LSTREAM)

module LsSeq = (struct
  include BatSeq
  (* Modified version of BatSeq.concat in batteries *)
  let expand_map f g s = 
    let rec aux current rest () = match current () with
      | Cons(e, s) ->
          Cons(g e, aux s rest)
      | Nil ->
          match rest () with
            | Cons(e, s) ->
                aux (f e) s ()
            | Nil ->
                Nil
    in
    aux nil s
  let expand f s = expand_map f (fun x -> x) s
  let fold = fold_left
  let force l = iter (fun x -> ()) l
  let clone l = l
  let of_list l = List.fold_right cons l nil
  let to_list l = BatList.of_enum (enum l)
  let singleton x = cons x nil
end : LSTREAM)

module LsStream = (struct 
  include BatStream
  let expand_map f g l = map g (concat (map f l))
  let expand f l = concat (map f l)
  let fold f z l = foldl (fun x y -> (f x y, None)) z l
  let force l = iter (fun x -> ()) l
  let clone l = l (* Noooo *)
  let singleton x = cons x (of_list [])
end : LSTREAM)

module LsLazyList = (struct 
  include BatLazyList
  let expand_map f g l = map g (concat (map f l))
  let expand f l = concat (map f l)
  let fold = fold_left
  let force l = iter (fun x -> ()) l
  let clone l = l
  let singleton x = cons x nil
end : LSTREAM)

module Lstream = LsSeq

type lstream = (string * float array) Lstream.t

(** Arithmetic expressions. *)
type arit_expr = string Mini_calc.arit_tree

(** A rule of rewriting *)
type rule = {
  lhs : string ;
  vars : string list ;
  rhs : (string * (arit_expr list)) list ;
}

(** A complete Lsystem. *)
type lsystem = {
  name : string ;
  axiom : (string * (float list)) list ;
  rules : rule list
}
