open Glilis
open Lilis
open Cmdliner

let (@@) = BatPervasives.(@@)
let (|>) = BatPervasives.(|>)

exception NoLsys of string
exception NoLsysName of string * string

(* This allow to change easily the stream used. *)
module Lstream = LisSequence
module LsEn = Make(Lstream)
let eval_lsys = LsEn.eval_lsys

let get_lsystem file name =
  let c = open_in file in
  let bank_ls = LisUtils.from_channel c in
  close_in c;
  match name with
    | None   -> begin
        try List.hd bank_ls
        with Failure "hd" -> raise (NoLsys file)
      end
    | Some s -> begin
        try List.find (fun l -> l.name = s) bank_ls
        with Not_found -> raise (NoLsysName (file, s))
      end

let init_time, print_time =
  let time = ref (Unix.gettimeofday ()) in
  let init () = time := Unix.gettimeofday () in
  let print () = Printf.printf "Time elapsed : %f\n%!" (Unix.gettimeofday () -. !time) in
  init, print

let to_gtk (width, height) lstream =
  let lstream = Lstream.to_list lstream in

  let expose area ev =
    let turtle = new LisCairo.gtk_turtle area in
    turtle#fill () ;
    List.iter turtle#draw lstream ;
    turtle#apply () ;
    true
  in
  ignore(GMain.init());
  let window = GWindow.window ~width ~height ~title:"gLILiS" () in
  ignore (window#connect#destroy GMain.quit);

  let area = GMisc.drawing_area ~packing:window#add () in
  area#misc#set_double_buffered true;
  ignore(area#event#connect#expose (expose area));
  window#show ();
  GMain.main ()

let to_png (width, height) lstream file =
  let turtle = new LisCairo.png_turtle width height in
  turtle#fill () ;
  Lstream.iter turtle#draw lstream ;
  turtle#finish file

let to_svg_cairo (width, height) lstream file =
  let turtle = new LisCairo.svg_turtle file width height in
  turtle#fill () ;
  Lstream.iter turtle#draw lstream ;
  turtle#finish ()


#ifdef Tyxml
let to_svg size lstream file =
  let turtle = new LisTyxml.svg_turtle in
  Lstream.iter turtle#draw lstream ;
  let lsvg = LisTyxml.template size (turtle#to_string ()) in
  let buffer = open_out file in
  Svg.P.print ~output:(output_string buffer) lsvg ;
  close_out buffer
#endif

(** {2 Go go Cmdliner !} *)

(* We gather possible outputs options here.
   We need a little applicative functor magic manipulation. *)
let outputs = ref (Term.pure [])
let add_output cmdopt cmdfun =
  outputs := Term.(pure (fun x o -> (x, cmdfun) :: o) $ cmdopt $ !outputs)

(** {3 First, arguments.} *)

let bank =
  let doc = "Charge the $(docv) file as a L-system library" in
  Arg.(required & pos 0 (some non_dir_file) None & info [] ~docv:"BANK" ~doc)

let lname =
  let doc = "Draw the $(docv) L-system from the selected library" in
  Arg.(value & pos 1 (some string) None & info [] ~docv:"NAME" ~doc)

let generation =
  let doc = "Generate the L-system at the n-th generation" in
  Arg.(required & opt (some int) None & info ["n"] ~docv:"GEN" ~doc)

let size =
  let doc = "The size of the image, in pixels" in
  Arg.(value & opt (pair int int) (700,700) & info ["s"; "size"] ~docv:"SIZE" ~doc)

let bench =
  let doc = "Print the time of execution" in
  Arg.(value & flag & info ["b";"bench"] ~docv:"BENCH" ~doc)

let verbose =
  let doc = "Be verbose" in
  Arg.(value & flag & info ["v"] ~doc)

let gtk =
  let doc = "Open a GTK window and draw the L-system." in
  Arg.(value & flag & info ["gtk"] ~doc)

let png =
  let doc = "Write a png to $(docv)." in
  Arg.(value & opt (some string) None & info ["png"] ~docv:"FILE" ~doc)
let () = add_output png to_png

#ifdef Tyxml
let svg =
  let doc = "Write a svg to $(docv)." in
  Arg.(value & opt (some string) None & info ["svg"] ~docv:"FILE" ~doc)
let () = add_output svg to_svg
#endif

let svg_cairo =
  let doc = "Write a svg to $(docv) with the cairo backend." in
  Arg.(value & opt (some string) None & info ["svg-cairo"] ~docv:"FILE" ~doc)
let () = add_output svg_cairo to_svg_cairo

(** {3 Then, terms.} *)

let parsing_t bank lname =
  try
    let lsys = get_lsystem bank lname in
    `Ok lsys
  with
    | NoLsys file ->
      `Error ( false , Printf.sprintf
        "The file %s doesn't contain any L-system." file )
    | NoLsysName (file,lname) ->
      `Error ( false , Printf.sprintf
        "The file %s doesn't contain any L-system named %s." file lname )
    | LisUtils.ParseError perr -> `Error (false, LisUtils.string_of_ParseError perr)
    | LisUtils.ArityError ( symb , d , u ) ->
      `Error ( false , Printf.sprintf
        "The symbol %s takes %i argument but is used with %i arguments."
        symb d u )
    | LisUtils.VarDefError ( symb, v ) ->
      `Error ( false, Printf.sprintf
        "In the rule %s, the variable %s is undefined."
        symb v )
    | LisUtils.TokenDefError symb ->
      `Error ( false, Printf.sprintf
        "The symbol %s is undefined."
        symb)
    | LisUtils.OptionalArgument (symb, arg) ->
      `Error ( false, Printf.sprintf
        "The symbol %s is called without the %s argument, while it is not optional.."
        symb arg )


let optim_t lsys =
  lsys
  |> LisOptim.constant_folding

let processing_t bench n lsys =
  let lsys = LisUtils.replace_in_post_rules Glilis.orders lsys in
  if bench then init_time () ;
  let lstream = eval_lsys n lsys in
  lstream

let draw_t bench size outputs gtk lstream =
  let fstream = Lstream.store lstream in
  List.iter
    (fun (x,f) -> BatOption.may (f size (Lstream.gennew fstream)) x)
    outputs ;
  if gtk then to_gtk size (Lstream.gennew fstream)
  (* This is kinda hacky, we force the evaluation of the stream to be able to benchmark the engine part alone. *)
  else Lstream.force lstream ;
  if bench then print_time () ;
  ()

let main_t =
  let open Term in
  let lsys = pure optim_t $ ret (pure parsing_t $ bank $ lname) in
  let lstream = pure processing_t $ bench $ generation $ lsys in
  pure draw_t $ bench $ size $ !outputs $ gtk $ lstream

let () =
  match Term.eval (main_t, Term.info "glilis") with
    | `Error _ -> exit 1 | _ -> exit 0
