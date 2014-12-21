
(* For @@ operator on ocaml <= 4.01 *)
open LisCommon


let real_pos size x =
  int_of_float (size *. x)

let c = real_pos 255.

let rgb r g b = Graphics_js.rgb (c r) (c g) (c b)

let jsturtle canvas =
  let open Glilis in
  let super = turtle () in

  Graphics_js.open_canvas canvas ;

  let size_x = ref @@ float_of_int @@ Graphics_js.size_x () in
  let size_y = ref @@ float_of_int @@ Graphics_js.size_y () in

  let move ?(trace=true) f =
    super.move ~trace f ;
    let { x ; y } = super.get_pos () in
    let x = real_pos !size_x x in
    let y = real_pos !size_y (1. -. y) in
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
    let x = real_pos !size_x x in
    let y = real_pos !size_y (1. -. y) in
    Graphics_js.moveto x y
  in

  let color c =
    super.color c ;
    let open Glilis in
    let {r;g;b;_} = c in
    Graphics_js.set_color @@ rgb r g b ;
  in

  let handle_lsys f =
    size_x := float_of_int @@ Graphics_js.size_x () ;
    size_y := float_of_int @@ Graphics_js.size_y () ;
    Graphics_js.clear_graph () ;
    let {r;g;b;_} = super.get_color () in
    Graphics_js.set_color @@ rgb r g b ;
    Graphics_js.set_line_width 1 ;
    super.handle_lsys f ;
  in

  {super with color ; move ; restore_position ; handle_lsys }
