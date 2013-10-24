open Ls_type

module SMap = BatMap.Make(BatString)

(** {2 Verifications} *)

(** We have to verity two sort of things :
  - Arity is consistent across a L-system.
  - Every variables used in a rule is defined.
*)

(** {3 Arity check} *)

exception ArityError of ( string * string * int * int )

let check_arity lsys =
  let add_arity (symb,used_arity) env =
    match SMap.Exceptionless.find symb env with
      | Some defined_arity ->
          if defined_arity = used_arity then env else
            let arity_e = (lsys.name, symb, defined_arity, used_arity ) in
            raise (ArityError arity_e)
      | None -> SMap.add symb used_arity env
  in
  let arity_env = List.fold_left
      (fun env r -> add_arity (r.lhs, List.length r.vars) env)
      SMap.empty lsys.rules
  in
  let _arity_env = List.fold_left
      (fun env r ->
         List.fold_left (fun env (s,l) -> add_arity (s, List.length l) env) env r.rhs)
      arity_env lsys.rules
  in
  ()

(** {3 Variable definition check} *)

exception VarDefError of ( string * string * string )

let check_vardef lsys env =
  let check_rule r =
    let is_def variable =
      if not (Mini_calc.Env.mem variable env || List.mem variable r.vars) then
        raise (VarDefError ( lsys.name, r.lhs, variable ))
    in
    let check_expr e =
      let l = Mini_calc.get_vars e in
      List.iter is_def l
    in
    List.iter (fun (_,l) -> List.iter check_expr l) r.rhs
  in
  List.iter check_rule lsys.rules
