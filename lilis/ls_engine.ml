open Ls_type
open Ls_utils

(** We compress arithmetic expression in two ways :
  - regular compression by evaluation
  - replace the environment by an array lookup
*)

type arit_fun = float array -> float

(* [vars] provides the string -> int mapping for variables.
   Will crash horribly if the mapping is imcomplete, which shouldn't happen if the compression functions are used.
*)
let arit_closure vars ( t : arit ) : arit_fun =
  let open Mini_calc in
  let t = compress_tree Env.usual t in
  let f x = BatArray.findi ( BatString.equal x) vars in
  let t = map_tree f t in
  let aclosure env =
    eval_tree_custom (Array.unsafe_get env) t
  in aclosure


(** The symbol environment contains the association int <-> string for Lsystem symbols. *)

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

  (** Extract the symbol environment from an Lsystem. *)
  (* It's basically a big multi-fold along lsystem rules. *)
  let extract axiom rules =
    let senv = add_axiom empty axiom in
    List.fold_left add_rule senv rules

end

open SymbEnv



module Engine (Ls : Ls_stream.S) = struct

  (** {1 Compression} *)

  (** We are going to compress The lsystem representation as much as possible.
    This means the following :
    - Replace every string by an int.
    - Replace every list by an array.
    - Use int symbols to replace association lists by an array lookup
  *)


  (** Compressed variations of types in [ Ls_type ]. *)

  type 'a lstream = ('a * (float array)) Ls.t
  type 'a crule = ('a * (arit_fun array)) Ls.t
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

  (** {3 Lsystem Transformation}
      Transform an Lsystem to a compressed form using a string <-> int mapping. *)

  let transform_rule_rhs symbf vars r : 'a crule =
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

  let compress_post_rules senv f rules : 'a crules =
    let crules = BatArray.create senv.n None in
    let add_rule r =
      let i, rhs = transform_rule senv f r in
      crules.(i) <- Some rhs
    in
    List.iter add_rule rules ;
    crules

  let compress_rules senv rules : 'a crules =
    compress_post_rules senv (fun x -> SMap.find x senv.env) rules

  let compress_lsys axiom rules =
    let senv = extract axiom rules in
    let caxiom = compress_lslist senv axiom in
    let crules = compress_rules senv rules in
    senv, caxiom, crules

  (** {1 Lsystem evaluation engine} *)

  (** Evaluate a stream of arithmetic expressions in the given environment. *)
  (* PERF There is an Array.map here, we can probably avoid it. *)
  let eval_rule args (lstream : 'a crule) : 'a lstream =
    let f_eval_rule (ordre, (ordre_args : arit_fun array) ) =
      ordre, Array.map (fun f -> f args) ordre_args
    in Ls.map f_eval_rule (Ls.clone lstream)

  (** Get the transformation function from a Lsystem. *)
  let get_transformation rules =
    let transf ((symbol,args) as tok) = match rules.(symbol) with
        Some x -> eval_rule args x
      | None -> Ls.singleton tok
    in transf

  (** Verify that a rule is complete and obtain the transformation. *)
  let get_complete_transformation rules =
    let empty = Ls.empty () in
    let f = function
      | Some x -> x
      | None -> empty
    in
    let r = Array.map f rules in
    let transf (symbol,args) = eval_rule args r.(symbol) in
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

  let apply_complete rules lstream =
    Ls.expand
      (get_complete_transformation rules)
      lstream

  let apply ?(n=1) rules lstream =
    generate_lstream n
      (get_transformation rules)
      lstream

  (** Generate the n-th generation of the given Lsystem. *)
  let eval_lsys n lsys =
    let senv, axiom, rules = compress_lsys lsys.axiom lsys.rules in
    let lstream = apply ~n rules axiom in
    uncompress_lstream senv lstream
end
