
let real_pos size x =
  (floor (size *. x)) +. 0.5

class ['a] cairo_turtle size_x size_y context =

  object (o) inherit ['a] Glilis.vturtle as super

    (* We do the scaling and the rounding by ourself here because cairo do it too slowly *)
    method move ?(trace=true) f =
      super#move ~trace f ;
      let open Glilis in
      (* Here is a little cheat to have real 1px line *)
      let { x ; y } = super#get_pos in
      let x = real_pos size_x x in
      let y = real_pos size_y y in
      if trace
      then Cairo.line_to context x y
      else Cairo.move_to context x y

    method restore_position () =
      super#restore_position () ;
      let open Glilis in
      let {r;g;b;a} = super#get_color in
      Cairo.set_source_rgba context r g b a ;
      let { x ; y } = super#get_pos in
      let x = real_pos size_x x in
      let y = real_pos size_y y in
      Cairo.move_to context x y

    method color c =
      super#color c ;
      let open Glilis in
      let {r;g;b;a} = c in
      Cairo.stroke context ; (* Only one color by stroke, so we stroke first *)
      Cairo.set_source_rgba context r g b a ;
      (* We need to fix the position after stroking. ~preserve sucks, so we don't use it.*)
      let { x ; y } = super#get_pos in
      let x = real_pos size_x x in
      let y = real_pos size_y y in
      Cairo.move_to context x y

    (** Fill the picture with solid white and set the color to solid black *)
    method fill () =
      Cairo.set_source_rgb context 1. 1. 1.;
      Cairo.paint context ~alpha:0.;
      Cairo.set_source_rgba context 0. 0. 0. 1.

    (** Apply drawing on the surface *)
    method apply () =
      Cairo.stroke context

  end

class ['a] png_turtle size_x size_y =

  let surface = Cairo.Image.create Cairo.Image.ARGB32 size_x size_y in
  let ctx = Cairo.create surface in
  let _ = Cairo.set_line_width ctx 1. in

  object inherit ['a] cairo_turtle (float size_x) (float size_y) ctx

    method finish file =
      Cairo.stroke ctx ;
      Cairo.PNG.write surface file
  end

class ['a] svg_turtle outfile size_x size_y =

  let width, height = (float size_x), (float size_y) in
  let surface = Cairo.SVG.create ~fname:outfile ~width ~height in
  let ctx = Cairo.create surface in
  let _ = Cairo.set_line_width ctx 0.5 in

  object inherit ['a] cairo_turtle width height ctx as super

    method finish () =
      Cairo.stroke ctx ;
      Cairo.Surface.flush surface ;
      Cairo.Surface.finish surface ;
  end

class ['a] gtk_turtle w =
  let ctx = Cairo_gtk.create w#misc#window in
  let { Gtk.width = size_x ; Gtk.height = size_y } = w#misc#allocation in
  let _ = Cairo.set_line_width ctx 0.5 in

  object inherit ['a] cairo_turtle (float size_x) (float size_y) ctx

  end
