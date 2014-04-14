(** Batteries streams implementations. *)

let id = BatFun.identity

(** Seq from batteries. Functionnal (allow sharing). *)
module Seq = struct
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
  let of_list l = List.fold_right cons l nil
  let to_list l =
    fold_right (fun h t -> h :: t) l []
  let singleton x = cons x nil
  let empty = nil
  let store x = iter ignore x ; x
  let gennew = id
end

(** Gen from batteries, imperative. *)
module Gen = struct
  include BatGen
  type 'a stored = 'a Restart.t
  let force l = iter (fun _ -> ()) l
  let expand = flat_map
  let of_list l = Restart.of_list l
  let empty = Restart.empty
  let store = persistent
  let gennew = start
end

(** Regular lazy list from batteries. Functionnal. *)
module LazyList = struct
  include BatLazyList
  type 'a stored = 'a t
  let expand f l = concat (map f l)
  let fold = fold_left
  let singleton x = cons x nil
  let empty = nil
  let of_list l = of_list l
  let store x = iter ignore x ; x
  let gennew = id
end

(** Stream from the standard library. Use batteries for convenience. Destructive reading, imperative. *)
module Stream = struct
  include BatStream
  type 'a stored = 'a list
  let rec expand f l =
    Stream.slazy
      (fun () ->
         match Stream.peek l with
           | Some p ->
               let p' = f p in
               Stream.junk l;
               Stream.iapp p' (Stream.slazy (fun () -> expand f l))
           | None -> Stream.sempty)
  let fold f z l = foldl (fun x y -> (f x y, None)) z l
  let of_list = id
  let singleton x = cons x (BatStream.of_list [])
  let store s = to_list s
  let empty = []
  let gennew l = BatStream.of_list l
end
