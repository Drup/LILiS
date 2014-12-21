(** {{:https://github.com/c-cube/ocaml-containers}companion_cube's containers} *)

(** CCKList, Persistent. *)
module KList : Lilis.S
  with type 'a t      = 'a CCKList.t
   and type 'a stored = 'a CCKList.t
