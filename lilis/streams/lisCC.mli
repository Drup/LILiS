(** {{:https://github.com/c-cube/ocaml-containers}companion_cube's containers} *)

(** Gen, Imperative. *)
module Gen : Lilis.S
  with type 'a t      = 'a CCGen.t
   and type 'a stored = 'a CCGen.Restart.t

(** CCKList, Persistent. *)
module KList : Lilis.S
  with type 'a t      = 'a CCKList.t
   and type 'a stored = 'a CCKList.t
