
type path_inst = 
  | M of (float * float)
  | Mr of (float * float)
  | L of (float * float)
  | Lr of (float * float)

let path_inst_to_string = function
  | M (x,y)  -> Printf.sprintf " M %f %f " x y
  | Mr (x,y) -> Printf.sprintf " m %f %f " x y
  | L (x,y)  -> Printf.sprintf " L %f %f " x y
  | Lr (x,y) -> Printf.sprintf " l %f %f " x y

class svg_turtle =

  object inherit Graphic_order.turtle as super

    val acc = BatEnum.empty ()

    method move ?(trace=true) d =
      super#move ~trace d ;
      if trace 
      then BatEnum.push acc (L (x,y))
      else BatEnum.push acc (M (x,y))

    method restore_position () = 
      super#restore_position () ;
      BatEnum.push acc (M (x,y))

    (** Export the path as a string. *)
    method to_string () = 
      let concat_acc s o =
	BatText.append (BatText.of_string (path_inst_to_string o)) s
      in 
      BatText.to_string (BatEnum.fold concat_acc BatText.empty acc)

  end

let a_stroke s : [> `Stroke ] Svg.M.attrib =
  Svg.M.to_attrib (Xml.string_attrib "stroke" s)

let a_strokewidth f : [> `Stroke_Width ] Svg.M.attrib =
  Svg.M.to_attrib (Xml.float_attrib "stroke-width" f)

let a_fill' f : [> `Fill ] Svg.M.attrib =
  Svg.M.to_attrib (Xml.string_attrib "fill" f)

let path' ?(a=[]) l = let _a = a in Svg.M.(tot (toelt (path ~a:_a l)))

let template (w,h) s = 
  let open Svg.M in
  svg
    ~a:[
      a_width (float w, Some `Px) ; a_height (float h, Some `Px) ;
      a_viewbox (0., 0., 1., 1.)
    ]
    [path' 
       ~a:[a_d ("M 0 0" ^ s) 
	  ; a_stroke "black" 
	  ; a_strokewidth 0.001
	  ; a_fill' "transparent" 
	  ] 
       []
    ]
