(* OASIS_START *)
(* DO NOT EDIT (digest: d41d8cd98f00b204e9800998ecf8427e) *)
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
               A"-short-functors";
               A"-charset"; P "utf-8"
              ]);
        | _ -> ()
  )
