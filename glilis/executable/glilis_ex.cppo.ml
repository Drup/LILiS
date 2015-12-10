open Glilis
open Lilis
open Cmdliner

(* For @@ operator on ocaml <= 4.01 *)
open LisCommon

exception NoLsys of string
exception NoLsysName of string * string

(* This allow to change easily the stream used. *)
module Lstream = LisSequence
module LsEn = Make(Lstream)

let get_lsystem file name =
  let c = open_in file in
  let bank_ls = LisUtils.from_channel c in
  close_in c;
  match name with
    | None   -> begin match bank_ls with
        | h :: _ -> h
        | _ -> raise @@ NoLsys file
      end
    | Some s -> begin
        try List.find (fun l -> l.name = s) bank_ls
        with Not_found -> raise @@ NoLsysName (file, s)
      end

let to_gtk (width, height) lstream =
  ignore(GMain.init());
  let window = GWindow.window ~width ~height ~title:"gLILiS" () in
  ignore (window#connect#destroy GMain.quit);

  let area = GMisc.drawing_area ~packing:window#add () in
  area#misc#set_double_buffered true;

  let expose ev =
    let turtle = LisCairo.gtk_turtle area in
    turtle.handle_lsys @@ lstream ~store:true @@ Glilis.transform_rhs turtle;
    true
  in
  ignore(area#event#connect#expose expose);
  window#show ();
  GMain.main ()

let to_png (width, height) lstream file =
  let turtle = LisCairo.png_turtle width height in
  let lstream = lstream ~store:false @@ Glilis.transform_rhs turtle in
  turtle.handle_lsys lstream file

let to_svg_cairo (width, height) lstream file =
  let turtle = LisCairo.svg_turtle file width height in
  let lstream = lstream ~store:false @@ Glilis.transform_rhs turtle in
  turtle.handle_lsys lstream




let check = function
  | Result.Ok x -> x
  | Result.Error (`Msg msg) -> failwith msg
let gl_set_attribute x y = check (Tsdl.Sdl.gl_set_attribute x y)

let init_scene (width, height) =
  let open Tgles2 in
  let open Tsdl in
  check @@ Sdl.init Sdl.Init.(timer + video);
  at_exit Sdl.quit;

  gl_set_attribute Sdl.Gl.context_profile_mask Sdl.Gl.context_profile_core;
  gl_set_attribute Sdl.Gl.context_major_version 3;
  gl_set_attribute Sdl.Gl.context_minor_version 0;

  (* Do double buffering in GL *)
  gl_set_attribute Sdl.Gl.doublebuffer 1;
  gl_set_attribute Sdl.Gl.depth_size 24;

  let window = check @@
    Sdl.create_window "gLILiS" ~w:width ~h:height
      Sdl.Window.(opengl + shown + resizable)
  in

  let context = check @@ Sdl.gl_create_context window in

  window, context

let to_gl (width, height) lstream =
  let open Tgles2 in
  let open Tsdl in
  let window, context = init_scene (width, height) in
  let width = ref width and height = ref height in
  let canvas = Wall_canvas.create_gl ~antialias:true in
  let event = Sdl.Event.create () in
  let turtle = LisGl.turtle canvas in
  let f = lstream ~store:true @@ Glilis.transform_rhs turtle in

  let draw () =
    Gl.clear_color 1.0 1.0 1.0 1.0;
    Gl.clear (Gl.depth_buffer_bit lor
        Gl.stencil_buffer_bit lor
        Gl.color_buffer_bit);
    Gl.viewport 0 0 !width !height;
    turtle.handle_lsys f (float !width) (float !height) ;
    Sdl.gl_swap_window window
  in

  (* The main event loop *)
  let rec loop () =
    let action = match Sdl.wait_event (Some event) with
      | Error (`Msg s) -> print_endline s ; `Quit
      | Ok () -> begin
        match Sdl.Event.(enum (get event typ)) with
        | `Quit -> `Quit
        | `Window_event
          when Sdl.Event.(get event window_event_id = window_event_resized) ->
          let w = Sdl.Event.(get event window_data1) in
          let h = Sdl.Event.(get event window_data2) in
          width := Int32.to_int w;
          height := Int32.to_int h;
          `Draw
        | _ -> `Skip
      end
    in
    match action with
    | `Quit -> ()
    | `Skip -> loop ()
    | `Draw -> draw () ; loop ()
  in
  draw () ; loop ()

;;

#ifdef def_tyxml
let to_svg size lstream file =
  let turtle = LisTyxml.svg_turtle () in
  let lstream = lstream ~store:false @@ Glilis.transform_rhs turtle in
  let s = turtle.handle_lsys lstream in
  let lsvg = LisTyxml.template size s in
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

let verbose =
  let doc = "Be verbose" in
  Arg.(value & flag & info ["v"] ~doc)

let gtk =
  let doc = "Open a GTK window and draw the L-system." in
  Arg.(value & flag & info ["gtk"] ~doc)

let opengl =
  let doc = "Open an OpenGl window and draw the L-system." in
  Arg.(value & flag & info ["gl"] ~doc)

let png =
  let doc = "Write a png to $(docv)." in
  Arg.(value & opt (some string) None & info ["png"] ~docv:"FILE" ~doc)
let () = add_output png to_png

#ifdef def_tyxml
let svg =
  let doc = "Write a svg to $(docv)." in
  Arg.(value & opt (some string) None & info ["svg"] ~docv:"FILE" ~doc)
let () = add_output svg to_svg
#endif

let svg_cairo =
  let doc = "Write a svg to $(docv) with the cairo backend." in
  Arg.(value & opt (some string) None & info ["cairo-svg"] ~docv:"FILE" ~doc)
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
  |> LisOptim.compress_calcs

let processing_t n lsys =
  let lstream = LsEn.eval_iter_lsys n lsys in
  lstream

let draw_t size outputs gtk opengl lstream =
  List.iter
    (fun (x,f) -> CCOpt.iter (f size lstream) x)
    outputs ;
  if gtk then to_gtk size lstream
  else if opengl then to_gl size lstream

let main_t =
  let open Term in
  let lsys = pure optim_t $ ret (pure parsing_t $ bank $ lname) in
  let lstream = pure processing_t $ generation $ lsys in
  pure draw_t $ size $ !outputs $ gtk $ opengl $ lstream

let () =
  match Term.eval (main_t, Term.info "glilis") with
    | `Error _ -> exit 1 | _ -> exit 0
