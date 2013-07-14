
type path_inst =
  | M of (float * float)
  | Mr of (float * float)
  | L of (float * float)
  | Lr of (float * float)

let path_inst_to_string = function
  | M (x,y)  -> Printf.sprintf "M %f %f " x y
  | Mr (x,y) -> Printf.sprintf "m %f %f " x y
  | L (x,y)  -> Printf.sprintf "L %f %f " x y
  | Lr (x,y) -> Printf.sprintf "l %f %f " x y

class svg_turtle =

  let push_inst acc x = 
    BatText.append acc (BatText.of_string (path_inst_to_string x))
  in

  object inherit Graphic_order.turtle as super

    val mutable acc = BatText.of_string "M 0 0 "

    method move ?(trace=true) f =
      super#move ~trace f ;
      let open Graphic_order in
      if trace
      then acc <- push_inst acc (L (pos.x,pos.y))
      else acc <- push_inst acc (M (pos.x,pos.y))

    method restore_position () =
      super#restore_position () ;
      let open Graphic_order in
      acc <- push_inst acc (M (pos.x,pos.y))

    (** Export the path as a string. *)
    method to_string () =
      BatText.to_string acc

  end

let a_stopcolor s : [> `Stop_Color ] Svg.M.attrib =
  Svg.M.to_attrib (Xml.string_attrib "stop-color" s)

let a_stroke s : [> `Stroke ] Svg.M.attrib =
  Svg.M.to_attrib (Xml.string_attrib "stroke" s)

let a_strokewidth f : [> `Stroke_Width ] Svg.M.attrib =
  Svg.M.to_attrib (Xml.float_attrib "stroke-width" f)

let a_fill' f : [> `Fill ] Svg.M.attrib =
  Svg.M.to_attrib (Xml.string_attrib "fill" f)

(* `Gradient_Stop instead of Stop *)
(* generate "gradient-stop" instead of "stop" *)
let gradientstop' ?(a=[]) l = let _a = a in Svg.M.(tot (toelt (gradientstop ~a:_a l)))

(* `Linear_Gradient instead of LinearGradient *)
(* generate "linear-gradient" instead of "linearGradient" *)
let lineargradient' ?(a=[]) l = let _a = a in Svg.M.(tot (toelt (lineargradient ~a:_a l)))

(* Should be allowed in svg *)
let path' ?(a=[]) l = let _a = a in Svg.M.(tot (toelt (path ~a:_a l)))

(* viewbox generates "viewbox" instead of "viewBox" *)

let template (w,h) s = 
  let open Svg.M in
  svg
    ~a:[
      a_width (float w, Some `Px) ; a_height (float h, Some `Px) ;
      a_viewbox (0., 0., 1., 1.)
    ]
    [lineargradient' ~a:[a_id "Gradient"] 
       [ gradientstop' ~a:[a_offset (`Percentage 0) ; a_stopcolor "blue"] [] ;
	 gradientstop' ~a:[a_offset (`Percentage 33) ; a_stopcolor "green"] [] ;
	 gradientstop' ~a:[a_offset (`Percentage 66) ; a_stopcolor "yellow"] [] ;
	 gradientstop' ~a:[a_offset (`Percentage 100) ; a_stopcolor "red"] [] ;
       ] ;
     path' 
       ~a:[a_d ("M 0 0" ^ s) 
	  ; a_stroke "url(#Gradient)"
	  ; a_strokewidth 0.001
	  ; a_fill' "transparent" 
	  ] 
       []
    ]
