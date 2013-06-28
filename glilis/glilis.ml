open Graphic_order
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
  let expose area ev =
    let turtle = new Crayon.turtle (Crayon.Gtk area) in
    turtle#fill () ;
    draw turtle (BatEnum.clone lstream) ;
    turtle#draw () ;
    true
  in
  ignore(GMain.init());
  let window = GWindow.window ~width ~height ~title:"gLILiS" () in
  ignore (window#connect#destroy GMain.quit);

  let area = GMisc.drawing_area ~packing:window#add () in
  area#misc#set_double_buffered false;
  ignore(area#event#connect#expose (expose area));
  window#show ();
  GMain.main ()

let to_png (width, height) lstream file =
  let turtle = new Crayon.turtle (Crayon.Picture (width, height)) in
  turtle#fill() ;
  draw turtle lstream ;
  turtle#draw () ;
  turtle#write file

(** Go go Cmdliner ! *)

let bank = 
  let doc = "Charge the $(docv) file as a Lsystem library" in
  Arg.(required & pos 0 (some string) None & info [] ~docv:"BANK" ~doc)

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

let png = 
  let doc = "Write a png in $(docv) instead of opening a window" in
  Arg.(value & opt (some string) None & info ["png"] ~docv:"FILE" ~doc)

let main n bank size bench verbose png =
  let lsys = get_lsystem bank in
  if bench then init_time () ;
  let lstream = eval_lsys n lsys in
  if verbose then print_endline "I'm computing and drawing !" ;
  begin match png with 
    | Some file -> to_png size lstream file 
    | None -> to_gtk size lstream
  end ;
  if verbose then print_endline "I'm done !" ; 
  if bench then print_time () ;
  print_endline "Bye !"
  
let main_t = Term.(pure main $ generation $ bank $ size $ bench $ verbose $ png)

let () = 
  match Term.eval (main_t, Term.info "glilis") with 
    | `Error _ -> exit 1 | _ -> exit 0
