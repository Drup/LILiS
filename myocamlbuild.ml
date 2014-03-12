(* OASIS_START *)
(* OASIS_STOP *)

let doc_intro = "doc/intro.text" in

let open Ocamlbuild_plugin in
dispatch
  (function hook ->
      dispatch_default hook ;
      match hook with
        | After_rules ->
            dep ["ocaml"; "doc"; "extension:html"] & [doc_intro] ;
            flag ["ocaml"; "doc"; "extension:html"] &
            (S[A"-t"; A"LILiS user guide";
               A"-intro"; P doc_intro;
               A"-colorize-code";
               A"-charset"; P "utf-8"
              ]);
        | _ -> ()
  )
