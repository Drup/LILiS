open Glilis
open Lilis
open Cmdliner

let get_lsystem file =
  let bank_ls = lsystem_from_chanel (open_in file) in
  let lsys = List.nth bank_ls 0 in
  lsys

let init_time, print_time =
  let time = ref (Unix.gettimeofday ()) in
  let init () = time := Unix.gettimeofday () in
  let print () = Printf.printf "Time elapsed : %f\n%!" (Unix.gettimeofday () -. !time) in
  init, print

let to_gtk (width, height) lstream =
  let lstream = Lstream.to_list lstream in

  let expose area ev =
    let turtle = new Ls_cairo.gtk_turtle area in
    turtle#fill () ;
    draw_list turtle lstream ;
    turtle#draw () ;
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
  let turtle = new Ls_cairo.png_turtle width height in
  turtle#fill () ;
  draw_enum turtle lstream ;
  turtle#finish file

let to_svg_cairo (width, height) lstream file =
  let turtle = new Ls_cairo.svg_turtle file width height in
  turtle#fill () ;
  draw_enum turtle lstream ;
  turtle#finish ()

let to_svg size lstream file =
  let turtle = new Ls_tyxml.svg_turtle in
  draw_enum turtle lstream ;
  let lsvg = Ls_tyxml.template size (turtle#to_string ()) in  
  let buffer = open_out file in
  Svg.P.print ~output:(output_string buffer) lsvg ;
  close_out buffer

(** Go go Cmdliner ! *)

let bank = 
  let doc = "Charge the $(docv) file as a Lsystem library" in
  Arg.(required & pos 0 (some non_dir_file) None & info [] ~docv:"BANK" ~doc)

let generation = 
  let doc = "Generate the Lsystem at the n-th generation" in
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
  let doc = "Open a GTK window and draw the lsystem." in
  Arg.(value & flag & info ["gtk"] ~doc)

let png = 
  let doc = "Write a png to $(docv)." in
  Arg.(value & opt (some string) None & info ["png"] ~docv:"FILE" ~doc)

let svg = 
  let doc = "Write a svg to $(docv)." in
  Arg.(value & opt (some string) None & info ["svg"] ~docv:"FILE" ~doc)

let svg_cairo = 
  let doc = "Write a svg to $(docv) with the cairo backend." in
  Arg.(value & opt (some string) None & info ["svg-cairo"] ~docv:"FILE" ~doc)


let main n bank size bench verbose png svg svg_cairo gtk =
  let lsys = get_lsystem bank in
  if bench then init_time () ;
  let lstream = eval_lsys n lsys in
  if verbose then print_endline "I'm computing and drawing !" ;

  List.iter 
    (fun (x,f) -> match x with Some x -> (f size (Lstream.clone lstream)) x | None -> ())
    [ png, to_png ;
      svg, to_svg ;
      svg_cairo, to_svg_cairo ] ;

  if gtk then to_gtk size lstream else Lstream.force lstream ;
  if verbose then print_endline "I'm done !" ; 
  if bench then print_time ()
  
let main_t = 
  let open Term in
  pure main $ generation $ bank 
  $ size $ bench $ verbose 
  $ png $ svg $ svg_cairo $ gtk

let () = 
  match Term.eval (main_t, Term.info "glilis") with 
    | `Error _ -> exit 1 | _ -> exit 0
