
(* For @@ operator on ocaml <= 4.01 *)
open LisCommon

let outline = Wall.Outline.{default with stroke_width = 0.1}

let stroke context {Glilis. r;g;b;a} =
  let paint = Wall.Paint.color @@ Gg.Color.v r g b a in
  Wall_canvas.stroke context paint outline

let turtle context =
  let open Glilis in
  let super = turtle () in
  let xf = ref Wall.Transform.identity in

  let move ?(trace=true) f =
    super.move ~trace f ;
    let { x ; y } = super.get_pos () in
    if trace
    then Wall_canvas.line_to context !xf ~x ~y
    else Wall_canvas.move_to context !xf ~x ~y
  in

  let restore_position () =
    super.restore_position () ;
    let open Glilis in
    let { x ; y } = super.get_pos () in
    Wall_canvas.move_to context !xf ~x ~y
  in

  let color c =
    (* Only one color by stroke, so we stroke first *)
    stroke context @@ super.get_color () ;

    super.color c ;
    let { x ; y } = super.get_pos () in
    Wall_canvas.move_to context !xf ~x ~y
  in

  let handle_lsys f sx sy =
    xf :=  Wall.Transform.(scale ~sx ~sy) ;
    Wall_canvas.new_frame context;
    Wall_canvas.new_path context ;
    f () ;
    stroke context @@ super.get_color () ;
    Wall_canvas.flush_frame context (Gg.Size2.v sx sy)
  in

  {super with color ; move ; restore_position ; handle_lsys }
