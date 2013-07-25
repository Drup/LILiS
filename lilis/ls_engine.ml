open Ls_type

(** We compress arithmetic expression in two ways :
  - regular compression by evaluation
  - replace the environment by an array lookup
*)

type arit_fun = float array -> float

(* [vars] provides the string -> int mapping for variables.
   Will crash horribly if the mapping is imcomplete. *)
let arit_closure vars ( t : arit_expr ) : arit_fun = 
  let open Mini_calc in
  let t = compress_tree Env.usual t in
  let f x = BatArray.findi ( (=) x) vars in
  let t = map_tree f t in
  fun env -> eval_tree_custom (fun x -> env.(x)) t


(** The symbol environment contains the association int <-> string for Lsystem symbols. *)

module SMap = BatMap.Make(BatString)

type senv = { n : int ; env : int SMap.t }

module SymbEnv = struct
  type t = senv

  let empty = { n = 0 ; env = SMap.empty }

  let add symb senv = 
    if SMap.mem symb senv.env
    then senv
    else { n = senv.n + 1; env = SMap.add symb senv.n senv.env }

  let to_array env =
    let v = Array.make (SMap.cardinal env) "" in
    SMap.iter (fun s i -> v.(i) <- s) env ;
    v

end

(** Extract the symbol environment from an Lsystem. *)
(* It's basically a big multi-fold along lsystem rules. *)
let extract_symbenv lsys = 
  let extract_rule_rhs r senv = 
    let transform_symb senv (symb,args) =
      SymbEnv.add symb senv
    in 
    List.fold_left transform_symb senv r
  in 
  let extract_rule senv r = 
    let senv = SymbEnv.add r.lhs senv in
    let senv = extract_rule_rhs r.rhs senv in
    senv
  in
  let senv = extract_rule_rhs lsys.axiom SymbEnv.empty in
  List.fold_left extract_rule senv lsys.rules


module Engine (Ls : Ls_stream.S) = struct
  
  (** {1 Compression} *)

  (** We are going to compress The lsystem representation as much as possible.
    This means the following : 
    - Replace every string by an int.
    - Replace every list by an array.
    - Use int symbols to replace association lists by an array lookup
  *)


  (** Compressed variations of types in [ Ls_type ]. *)
  
  type comp_lstream = (int * (float array)) Ls.t
  type comp_rule = (int * (arit_fun array)) Ls.t 
  type comp_lsystem = {
    caxiom : comp_lstream ;
    crules : comp_rule option array
  }

  (** {3 Stream compression} 
      Compress or uncompress a stream according to a string <-> int mapping. *)

  let compress_lslist senv lstream = 
    let fcl (s,l) = SMap.find s senv.env, Array.of_list l in
    Ls.of_list (List.map fcl lstream)

  let compress_lstream senv lstream = 
    let fcl (s,l) = SMap.find s senv, l in
    Ls.map fcl lstream

  let uncompress_lstream senv = 
    let v = SymbEnv.to_array senv in
    let ful (i,l) = v.(i), l in
    Ls.map ful

  (** {3 Lsystem Transformation}
      Transform an Lsystem to a compressed form using a string <-> int mapping. *)

  let transform_rule_rhs r vars senv : comp_rule =
    let transform_symb (symb,args) = 
      let new_symb = SMap.find symb senv.env in
      let new_args = Array.of_list (List.map (arit_closure vars) args) in
      new_symb, new_args
    in Ls.of_list (List.map transform_symb r)

  let transform_rule r senv = 
    let new_vars = Array.of_list r.vars in
    let new_lhs = SMap.find r.lhs senv.env in
    let new_rhs = transform_rule_rhs r.rhs new_vars senv in
    (new_lhs, new_rhs)

  let compress_lsys lsys =
    let senv = extract_symbenv lsys in
    let crules = BatArray.create senv.n None in
    let add_rule r = 
      let i, rhs = transform_rule r senv in
      crules.(i) <- Some rhs 
    in
    List.iter add_rule lsys.rules ; 
    let caxiom = compress_lslist senv lsys.axiom in
    let new_lsys = { caxiom ; crules } in
    senv.env, new_lsys
    
  (** {1 Lsystem evaluation engine} *)
          
  (** Evaluate a stream of arithmetic expressions in the given environment. *)
  (* PERF There is an Array.map here, we can probably avoid it. *)
  let eval_rule args (lstream : comp_rule) : comp_lstream =
    let f_eval_rule (ordre, (ordre_args : arit_fun array) ) =
      ordre, Array.map (fun f -> f args) ordre_args
    in Ls.map f_eval_rule (Ls.clone lstream)
    
  (** Get the transformation function from a Lsystem. *)
  let get_transformation rules =
    let transf symbol args = match rules.(symbol) with
        Some x -> eval_rule args x 
      | None -> Ls.singleton (symbol,args)
    in transf
      
  (** Generate a lstream at the n-th generation, 
      with the given axiom and the given transformation function. *)
  let generate_lstream m axiom transformation =
    if m < 0 then failwith "generate_lstream only accept positive integers as generation number" ;
    let map_transform lstream =
      Ls.expand (function (ordre,args) -> transformation ordre args) lstream
    in
    let rec generation n l = match n with
        0 -> l
      | n -> generation (n-1) (map_transform l)
    in
    generation m axiom

  let apply lsys ?(n=1) lstream = 
    generate_lstream n
      lstream
      (get_transformation lsys.crules)

  let eval_lsys_raw n lsys =
    apply lsys ~n lsys.caxiom

  (** Generate the n-th generation of the given Lsystem. *)
  let eval_lsys n lsys = 
    let senv, lsys' = compress_lsys lsys in
    let lstream = eval_lsys_raw n lsys' in
    uncompress_lstream senv lstream
end
