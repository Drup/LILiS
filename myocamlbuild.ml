(* OASIS_START *)
(* DO NOT EDIT (digest: d41d8cd98f00b204e9800998ecf8427e) *)
(* OASIS_STOP *)

open Ocamlbuild_plugin

let () =
  let prod = "%.ml" in
  let dep = "%.ml.cpp" in
  let f env _build =
    let dep = env dep in
    let prod = env prod in
    let tags = tags_of_pathname prod ++ "cppo" in
    Cmd (S[A "cppo"; A "-n"; T tags; S [A "-o"; P prod]; P dep ])
  in
  rule "cppo" ~dep ~prod f ;
  pflag ["cppo"] "define" (fun s -> S [A "-D"; A s]) ;
  pflag ["cppo"] "undef" (fun s -> S [A "-U"; A s]) ;
  pflag ["cppo"] "include" (fun s -> S [A "-I"; A s]) ;
  flag ["cppo"; "preserve_quotation"] (A "-q")

let doc_intro = "doc/intro.text"

let executable = "glilis/glilis_ex"

let () =
  dispatch
    (function hook ->
      dispatch_default hook ;
      let env_filename = Pathname.basename BaseEnvLight.default_filename in
      let env =
        BaseEnvLight.load
          ~filename:env_filename
          ~allow_empty:true
          ()
      in
      if BaseEnvLight.var_get "tyxml" env = "true" then
        begin
          tag_file (executable-.-"ml") [ "define(Tyxml)" ] ;
          tag_file (executable-.-"native") [ "use_tyxml"; "pkg_tyxml" ] ;
          tag_file (executable-.-"byte") [ "use_tyxml"; "pkg_tyxml" ] ;
        end
      ;
      match hook with
        | After_rules ->
            dep ["ocaml"; "doc"; "extension:html"] & [doc_intro] ;
            flag ["ocaml"; "doc"; "extension:html"] &
            (S[A"-t"; A"LILiS user guide";
               A"-intro"; P doc_intro;
              ]);
        | _ -> ()
    )
