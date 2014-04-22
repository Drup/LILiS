open LisCommon

(** {2 Types} *)

type 'a stream = ('a * float list) list

type 'a rule = {
  lhs : string ;
  vars : string list ;
  rhs : 'a list ;
}
(** A L-system rule. *)

type 'a lsystem = {
  name : string ;
  axiom : (string * string Calc.t list) list ;
  rules : (string * string Calc.t list) rule list ;
  post_rules : 'a rule list ;
}
(** A complete L-system. *)



(** We compress arithmetic expression in two ways :
  - regular compression by evaluation
  - replace the environment by an array lookup
*)

type arit_fun = float array -> float

(* [vars] provides the string -> int mapping for variables.
   Will crash horribly if the mapping is imcomplete, which shouldn't happen if the compression functions are used.
*)
let arit_closure v t : arit_fun =
  let open Calc in
  let t = compress Env.usual t in
  let f x = BatArray.findi ( BatString.equal x) v in
  let t = map f t in
  let aclosure env =
    eval_custom (Array.unsafe_get env) t
  in aclosure


(** The symbol environment contains the association int <-> string for L-system symbols. *)
module SymbEnv = struct
  type t = { n : int ; env : int SMap.t }

  let empty = { n = 0 ; env = SMap.empty }

  let add symb senv =
    if SMap.mem symb senv.env
    then senv
    else { n = senv.n + 1; env = SMap.add symb senv.n senv.env }

  let to_array env =
    let v = Array.make (SMap.cardinal env) "" in
    SMap.iter (fun s i -> v.(i) <- s) env ;
    v

  let add_axiom senv axiom =
    let transform_symb senv (symb,args) =
      add symb senv
    in
    List.fold_left transform_symb senv axiom

  let add_rule senv r =
    let senv = add r.lhs senv in
    let senv = add_axiom senv r.rhs in
    senv

  let add_post_rule senv r =
    add r.lhs senv

  (** Extract the symbol environment from an L-system. *)
  (* It's basically a big multi-fold along L-system rules. *)
  let extract axiom rules post_rules =
    let senv = add_axiom empty axiom in
    let senv = List.fold_left add_rule senv rules in
    List.fold_left add_post_rule senv post_rules

end

open SymbEnv

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

module Make (Ls : S) = struct

  (** {1 Compression} *)

  (** We are going to compress The L-system representation as much as possible.
    This means the following :
    - Replace every string by an int.
    - Replace every list by an array.
    - Use int symbols to replace association lists by an array lookup
  *)

  type 'a lstream = ('a * (float array)) Ls.t
  type 'a crule = ('a * (arit_fun array)) Ls.stored (* If the stream is transient *)
  type 'a crules = 'a crule option array

  (** {3 Stream compression}
      Compress or uncompress a stream according to a string <-> int mapping. *)

  let compress_lslist senv lstream =
    let fcl (s,l) = SMap.find s senv.env, Array.of_list l in
    Ls.of_list (List.map fcl lstream)

  let compress_lstream senv lstream =
    let fcl (s,l) = SMap.find s senv.env, l in
    Ls.map fcl lstream

  let uncompress_lstream senv =
    let v = SymbEnv.to_array senv.env in
    let ful (i,l) = v.(i), l in
    Ls.map ful

  (** {3 L-system Transformation}
      Transform an L-system to a compressed form using a string <-> int mapping. *)

  let transform_rule_rhs symbf vars r =
    let transform_symb (symb,args) =
      let new_symb = symbf symb in
      let new_args = Array.of_list (List.map (arit_closure vars) args) in
      new_symb, new_args
    in Ls.of_list (List.map transform_symb r)

  let transform_rule senv f r =
    let new_vars = Array.of_list r.vars in
    let new_lhs = SMap.find r.lhs senv.env in
    let new_rhs = transform_rule_rhs f new_vars r.rhs in
    (new_lhs, new_rhs)

  let compress_gen_rules senv f rules =
    let crules = BatArray.create senv.n None in
    let add_rule r =
      let i, rhs = transform_rule senv f r in
      crules.(i) <- Some rhs
    in
    List.iter add_rule rules ;
    crules

  let compress_post_rules senv rules =
    compress_gen_rules senv (fun x -> x) rules

  let compress_rules senv rules =
    let get x = SMap.find x senv.env in
    compress_gen_rules senv get rules

  (** Evaluate the axiom *)
  let eval_expr l =
    let f (name,l) =
      name, List.map Calc.(eval Env.empty) l
    in List.map f l

  let compress_lsys lsys =
    let senv = extract lsys.axiom lsys.rules lsys.post_rules in
    let caxiom = compress_lslist senv (eval_expr lsys.axiom) in
    let crules = compress_rules senv lsys.rules in
    let cprules = compress_post_rules senv lsys.post_rules in
    senv, caxiom, crules, cprules

  let map_crules f x  =
    let f' x = Ls.store @@ Ls.map (fun (a,b) -> (f a,b)) @@ Ls.gennew x in
    Array.map (BatOption.map f') x

  (** {1 L-system evaluation engine} *)

  (* Starting here, we need to be really carefull with boxing, specialisation and clotures.
     In particular *all* functions that take float array should be specialized to ensure it.
  *)

  (** Evaluate a stream of arithmetic expressions in the given environment. *)
  (* PERF There is an Array.map here, we can probably avoid it. *)
  let eval_rule args lstream =
    let f_eval_rule (ordre, (ordre_args : arit_fun array) ) =
      ordre, Array.map (fun f -> f args) ordre_args
    in Ls.map f_eval_rule (Ls.gennew lstream)

  let iter_rule (args : float array) lstream =
    let f_iter_rule (order, (ordre_args : arit_fun array)) =
      order ordre_args args
    in Ls.iter f_iter_rule (Ls.gennew lstream)

  let fold_rule (args : float array) lstream z =
    let f_iter_rule z (order, (ordre_args : arit_fun array)) =
      order ordre_args z args
    in Ls.fold f_iter_rule z (Ls.gennew lstream)


  (** Get the transformation function from a L-system. *)
  let get_transformation rules =
    let transf ((symbol,args) as tok) = match rules.(symbol) with
        Some x -> eval_rule args x
      | None -> Ls.singleton tok
    in transf

  (** Verify that a rule is complete and obtain the transformation. *)
  let get_complete_transformation eval rules =
    let f = function
      | Some x -> x
      | None -> Ls.empty
    in
    let r = Array.map f rules in
    let transf (symbol,args) = eval (args : float array) r.(symbol) in
    transf

  (** Generate a lstream at the n-th generation,
      with the given axiom and the given transformation function. *)
  let generate_lstream m transf axiom =
    if m < 0 then failwith "generate_lstream only accept positive integers as generation number" ;
    let rec generation n l = match n with
        0 -> l
      | n -> generation (n-1) (Ls.expand transf l)
    in
    generation m axiom

  let iter_complete rules lstream =
    Ls.iter
      (get_complete_transformation iter_rule rules)
      lstream

  let fold_complete rules z lstream =
    Ls.fold
      (fun z x -> get_complete_transformation fold_rule rules x z)
      z lstream

  let apply_complete rules lstream =
    Ls.expand
      (get_complete_transformation eval_rule rules)
      lstream

  let apply ?(n=1) rules lstream =
    generate_lstream n
      (get_transformation rules)
      lstream

  let eval_general n lsys =
    let senv, axiom, rules, prules = compress_lsys lsys in
    let lstream = apply ~n rules @@ Ls.gennew axiom in
    fun f -> f senv prules lstream

  (** Like eval_lsys, but will ignore post rules and uncompress the stream instead. *)
  let eval_lsys_uncompress n lsys =
    eval_general n lsys
      (fun env _ l -> uncompress_lstream env l)

  (** Generate the n-th generation of the given L-system. *)
  let eval_lsys n lsys =
    eval_general n lsys
      (fun _ prules l -> apply_complete prules l)

  let eval_iter_lsys n lsys =
    eval_general n lsys
      (fun _ prules l ~store spec ->
         if store then
           let l = Ls.store l in
           fun () -> iter_complete (map_crules spec prules) @@ Ls.gennew l
         else
           fun () -> iter_complete (map_crules spec prules) l
      )

  let eval_fold_lsys n lsys =
    eval_general n lsys
      (fun _ prules l ~store spec ->
         if store then
           let l = Ls.store l in
           fun z -> fold_complete (map_crules spec prules) z @@ Ls.gennew l
         else
           fun z -> fold_complete (map_crules spec prules) z l
      )

end
