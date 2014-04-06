
let iof = int_of_float

let real_pos size x =
  iof (size *. x)

let real_color c = iof (255. *. c)

class ['a] turtle size_x size_y evas_obj =

  (* let _ = Cairo.set_line_width ctx 0.5 in *)

  let size_x = float_of_int size_x in
  let size_y = float_of_int size_y in

  object (o) inherit ['a] Glilis.vturtle as super

    method move ?(trace=true) f =
      let open Efl in
      if trace then
        let {Glilis.  x ; y } = super#get_pos in
        super#move ~trace f ;
        let {Glilis. x = x' ; y = y' } = super#get_pos in
        let line = Evas_object.line_add evas_obj in
        Evas_object.line_xy_set line
          (real_pos size_x x) (real_pos size_y y)
          (real_pos size_x x') (real_pos size_y y') ;
        let {Glilis. r ; g ; b ; a} = super#get_color in
        Evas_object.color_set line
          (real_color r) (real_color g) (real_color b) (real_color a) ;
        Evas_object.show line;
      else
        super#move ~trace f ;

  end
