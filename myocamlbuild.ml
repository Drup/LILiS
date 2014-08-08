(* OASIS_START *)
(* DO NOT EDIT (digest: d41d8cd98f00b204e9800998ecf8427e) *)
(* OASIS_STOP *)

open Ocamlbuild_plugin

(** The introduction for the documentation, must be added as a dependency. *)
let doc_intro = "doc/intro.text"


(** Various utility function for conditional stuff through oasis. *)
let define s = Printf.sprintf "cppo_D(def_%s)" s
let use s = Printf.sprintf "use_%s" s
let pkg s = Printf.sprintf "package(%s)" s
let oasis_flag env flag = BaseEnvLight.var_get flag env = "true"


(** If the tyxml flag is set, compile with [-D def_tyxml] and link against tyxml. *)
let tyxml_cond env =
  if oasis_flag env "tyxml" then begin
    let path_exec = "glilis/executable" in
    let executable = path_exec / "glilis_ex" in
    let dep = "tyxml" in
    tag_file (executable-.-"ml")     [ use dep; pkg dep; define dep ] ;
    tag_file (executable-.-"native") [ use dep; pkg dep ] ;
    tag_file (executable-.-"byte")   [ use dep; pkg dep ] ;
    (* Insert magic here. I don't really know either. *)
    Pathname.define_context path_exec ["glilis/tyxml"]
  end


(** All the benchmark sources. *)
let bench_common = "test/bench_common"
let bench_targets =
  List.map ((^) "test/bench_") ["streams" ; "vonkoch" ; "quick" ; "optims" ]

(** Optional dependencies for the benchmarks. *)
let bench_opt_dep =
  ["batteries"; "sequence" ; "containers" ; "core" ; "cfstream" ]

(** For each flags in {!bench_opt_dep}, if it's enable,
    apply cppo on {!bench_common} and add the link on {!bench_targets}.
*)
let bench_cond env =
  List.iter (fun flag ->
    if oasis_flag env flag then
      tag_file (bench_common-.-"ml") [ define flag ; use flag; pkg flag])
    bench_opt_dep ;

  List.iter (fun flag ->
    List.iter (fun file ->
      if oasis_flag env flag then begin
        tag_file (file-.-"native") [ use flag; pkg flag ] ;
        tag_file (file-.-"byte")   [ use flag; pkg flag ]
      end)
      bench_targets)
    bench_opt_dep

let () =
  dispatch
    (function hook ->
      dispatch_default hook ;
      Ocamlbuild_cppo.dispatcher hook ;

      (** Get the env, once again. *)
      let env_filename = Pathname.basename BaseEnvLight.default_filename in
      let env =
        BaseEnvLight.load
          ~filename:env_filename
          ~allow_empty:true
          ()
      in

      (** Conditional stuff *)
      tyxml_cond env ;
      bench_cond env ;

      match hook with
        | After_rules ->
            dep ["ocaml"; "doc"; "extension:html"] & [doc_intro] ;
            flag ["ocaml"; "doc"; "extension:html"] &
            (S[A"-t"; A"LILiS user guide";
               A"-intro"; P doc_intro;
              ]);
        | _ -> ()
    )
