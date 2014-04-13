
let real_pos size x =
  (floor (size *. x)) +. 0.5

let cairo_turtle size_x size_y context =
  let open Glilis in
  let super = turtle () in

  (* We do the scaling and the rounding by ourself here because cairo do it too slowly *)
  let move ?(trace=true) f =
    super.move ~trace f ;
    (* Here is a little cheat to have real 1px line *)
    let { x ; y } = super.get_pos () in
    let x = real_pos size_x x in
    let y = real_pos size_y y in
    if trace
    then Cairo.line_to context x y
    else Cairo.move_to context x y
  in

  let restore_position () =
    super.restore_position () ;
    let open Glilis in
    let {r;g;b;a} = super.get_color () in
    Cairo.set_source_rgba context r g b a ;
    let { x ; y } = super.get_pos () in
    let x = real_pos size_x x in
    let y = real_pos size_y y in
    Cairo.move_to context x y
  in

  let color c =
    super.color c ;
    let open Glilis in
    let {r;g;b;a} = c in
    Cairo.stroke context ; (* Only one color by stroke, so we stroke first *)
    Cairo.set_source_rgba context r g b a ;
    (* We need to fix the position after stroking. ~preserve sucks, so we don't use it.*)
    let { x ; y } = super.get_pos () in
    let x = real_pos size_x x in
    let y = real_pos size_y y in
    Cairo.move_to context x y
  in

  let handle_lsys f =
    Cairo.set_line_width context 0.5 ;
    Cairo.set_source_rgb context 1. 1. 1.;
    Cairo.paint context ~alpha:0.;
    Cairo.set_source_rgba context 0. 0. 0. 1. ;
    super.handle_lsys f ;
    Cairo.stroke context
  in

  {super with color ; move ; restore_position ; handle_lsys }


let png_turtle size_x size_y =
  let open Glilis in

  let surface = Cairo.Image.create Cairo.Image.ARGB32 size_x size_y in
  let ctx = Cairo.create surface in

  let super = cairo_turtle (float size_x) (float size_y) ctx in

  let handle_lsys f file =
    super.handle_lsys f ;
    Cairo.PNG.write surface file
  in

  {super with handle_lsys }



let svg_turtle outfile size_x size_y =
  let open Glilis in

  let width, height = (float size_x), (float size_y) in
  let surface = Cairo.SVG.create ~fname:outfile ~width ~height in
  let ctx = Cairo.create surface in

  let super = cairo_turtle (float size_x) (float size_y) ctx in

  let handle_lsys f =
    super.handle_lsys f ;
    Cairo.Surface.flush surface ;
    Cairo.Surface.finish surface ;
  in

  {super with handle_lsys }


let gtk_turtle w =
  let open Glilis in
  let ctx = Cairo_gtk.create w#misc#window in
  let { Gtk.width = size_x ; Gtk.height = size_y } = w#misc#allocation in

  cairo_turtle (float size_x) (float size_y) ctx
