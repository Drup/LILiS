open LisCommon
open Lilis

module SSet = BatSet.Make(BatString)

let empty_rule s = { lhs = s ; vars = [] ; rhs = [] }

let get_used_symbols lsys =
  List.fold_right (fun sym -> SSet.add sym.lhs) lsys.rules SSet.empty

let get_symbols lsys =
  let set = SSet.empty in
  let add_axiom ax set = List.fold_right (fun sym -> SSet.add (fst sym)) ax set in
  let add_lhs rule set = SSet.add rule.lhs set in
  let add_rule rule set =
    let set = add_lhs rule set in
    add_axiom rule.rhs set
  in
  let set = add_axiom lsys.axiom set in
  let set = List.fold_right add_rule lsys.rules set in
  List.fold_right add_lhs lsys.post_rules set


let subst_var_in_token (symb, vars) substs =
  let vars' =
    List.map
      (fun x ->
         x
         |> Mini_calc.bind_opt (fun s -> BatList.Exceptionless.assoc s substs)
         |> Mini_calc.compress_custom (fun _ -> None)
      )
      vars
  in (symb, vars')

let apply_rule rule args =
  let substs = BatList.combine rule.vars args in
  let rhs =
    List.map
      (fun tok -> subst_var_in_token tok substs)
      rule.rhs
  in
  let vars =
    BatList.unique @@ BatList.concat @@ List.map Mini_calc.vars args
  in { rule with rhs ; vars }


(* We need to craft new unused names for the rules we add.
   The new name is a concatenation of the symboles + as many ' as needed to be unique. *)
let create_name nameset symbs =
  let rec name s =
    if SSet.mem s nameset
    then name (s ^ "'")
    else s
  in
  let n = name @@ String.concat "" symbs in
  (n, SSet.add n nameset)


let constant_folding lsys =

  (* Get the post_rules for some symbols. *)
  let get_rules lsys symbs =
    (* A symbol might not have a rule, we just use an empty rule in this case. *)
    let get_rule lsys (symb, _) =
      BatOption.default
        (empty_rule symb)
        @@ BatList.Exceptionless.find (fun x -> x.lhs = symb) lsys.post_rules
    in
    List.map (get_rule lsys) symbs
  in

  (* We synthethise a new rule by fusionning other rules.
     In practice, it's just a concatenation of vars and rhs. *)
  let fusion_rules name rules = {
    lhs = name ;
    vars = BatList.unique @@ List.concat @@ List.map (fun x -> x.vars) rules ;
    rhs = List.concat @@ List.map (fun x -> x.rhs) rules ;
  } in

  let synth_rule lsys nameset toks =
    let rules = get_rules lsys toks in
    let applied_rules = List.map2 apply_rule rules (List.map snd toks) in
    let (name, nameset) = create_name nameset (List.map fst toks) in
    let new_rule = fusion_rules name applied_rules in
    (new_rule, nameset)
  in

  let fusion_symbols used_rules nameset tokens =
    (* We gather the symbols that need fusion by making a buffer grows
       while we can fusion, and the fusion everything when we can't.
       - We need to reverse the buffer, since it's acc by the front. *)
    let rec aux nameset buffer new_rules = function
        [] -> begin
          if buffer = [] then ([], new_rules, nameset)
          else (* Don't forget to collapse the rules if the buffer is not empty. *)
            let (new_rule, nameset) = synth_rule lsys nameset (List.rev buffer) in
            let vars = List.map Mini_calc.var new_rule.vars in
            ([(new_rule.lhs , vars)], new_rule :: new_rules, nameset)
        end
      | ((sym,vars) as tok) :: t -> begin
          if SSet.mem sym used_rules then (* The name is used. *)
            if buffer = [] then (* either we don't have rule to collapse, just carry on. *)
              let (t, rules, nameset) = aux nameset [] new_rules t in
              (tok :: t, rules, nameset)
            else (* Or we do have rules to collapse, then let's go ! *)
              let (new_rule, nameset) = synth_rule lsys nameset (List.rev buffer) in
              let vars = List.map Mini_calc.var new_rule.vars in
              let (t, new_rules, nameset) = aux nameset [] new_rules t in
              ((new_rule.lhs , vars) :: tok :: t , new_rule :: new_rules, nameset)
          else (* Just add to the buffer. *)
            let (t, rules, nameset) = aux nameset (tok :: buffer) new_rules t in
            (t, rules, nameset)
        end
    in
    aux nameset [] [] tokens
  in

  let f used_rules rule nameset =
    let (rhs, new_post_rules, nameset) =
      fusion_symbols used_rules nameset rule.rhs in
    (nameset, ({rule with rhs}, new_post_rules))
  in
  let used_names = get_used_symbols lsys in
  let nameset = get_symbols lsys in

  let (axiom', post_rules', nameset) =
    fusion_symbols used_names nameset lsys.axiom in

  let ( _ , l) = foldAccum (f used_names) lsys.rules nameset in
  let rules' , post_rules'' = List.split l in
  { lsys with
      axiom = axiom' ;
      rules = rules' ;
      post_rules = List.concat (lsys.post_rules :: post_rules' :: post_rules'' )
  }
