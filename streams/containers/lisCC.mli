(** {{:https://github.com/c-cube/ocaml-containers}companion_cube's containers} *)

(** CCGen, Imperative, also available in the standalone package gen. *)
module Gen : Lilis.S
  with type 'a t      = 'a CCGen.t
   and type 'a stored = 'a CCGen.Restart.t

(** CCKList, Persistent. *)
module KList : Lilis.S
  with type 'a t      = 'a CCKList.t
   and type 'a stored = 'a CCKList.t


(** CCSequence, Persistent. also available in the standalone package sequence. *)
module Sequence : Lilis.S
  with type 'a t      = 'a CCSequence.t
   and type 'a stored = 'a CCSequence.t
