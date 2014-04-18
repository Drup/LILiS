
(* For @@ operator on ocaml <= 4.01 *)
open LisCommon


let real_pos size x =
  int_of_float (size *. x)

let c = real_pos 255.

let rgb r g b = Graphics_js.rgb (c r) (c g) (c b)

let gturtle size_x size_y =
  let open Glilis in
  let super = turtle () in

  let move ?(trace=true) f =
    super.move ~trace f ;
    let { x ; y } = super.get_pos () in
    let x = real_pos size_x x in
    let y = real_pos size_y y in
    if trace
    then Graphics_js.lineto x y
    else Graphics_js.moveto x y
  in

  let restore_position () =
    super.restore_position () ;
    let open Glilis in
    let {r;g;b;_} = super.get_color () in
    Graphics_js.set_color @@ rgb r g b ;
    let { x ; y } = super.get_pos () in
    let x = real_pos size_x x in
    let y = real_pos size_y y in
    Graphics_js.moveto x y
  in

  let color c =
    super.color c ;
    let open Glilis in
    let {r;g;b;_} = c in
    Graphics_js.set_color @@ rgb r g b ;
  in

  let handle_lsys f canvas =
    Graphics_js.open_canvas canvas ;
    Graphics_js.clear_graph () ;
    Graphics_js.set_line_width 1 ;
    super.handle_lsys f ;
  in

  {super with color ; move ; restore_position ; handle_lsys }
