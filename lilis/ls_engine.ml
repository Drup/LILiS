open Ls_type

(** Get the rule that match the given symbol *)
let rec get_rule ordre rules = match rules with
    [] -> None (* No rule match the symbol *)
  | t::q when t.left_mem = ordre -> Some t (* Found the rule matching the symbol *)
  | _::q -> get_rule ordre q

(** Eval l_stream in the environement env *)
let eval_stream env l_stream =
  let f_eval_stream (ordre,ordre_args) = 
    ordre, List.map (fun f -> f env) ordre_args
  in BatEnum.map f_eval_stream l_stream

(** Evalue les expressions arithmetiques d'une regle avec l'argument donne et renvoie un L_flux *)
let exec_rule arg rule =
  let env = List.fold_left2 (fun env k x -> Env.add k x env) Env.empty rule.var arg in
eval_stream env (BatList.enum rule.right_mem)


(** Get the transformation function from a Lsystem *)
let get_transformation lsys =
  let transf ordre arg = match get_rule ordre lsys.rules with
      None -> singleton (ordre,arg)
    | Some r -> exec_rule arg r
  in transf

(** Creation d'une courbe recursive de generation m, de premier element germe et de fonction transformation *)
let courbe_recursive m germe transformation =
  let developement lstream =
    BatEnum.concat (BatEnum.map (function (ordre,args) -> transformation ordre args) lstream)
  in
  let rec generation n l = match n with
      0 -> l
    | n -> generation (n-1) (developement l)
  in
  generation m germe

let eval_lsys n lsys = courbe_recursive n (BatList.enum lsys.axiom) (get_transformation lsys)
