
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

  object inherit Glilis.turtle as super

    val mutable acc = BatText.of_string "M 0 0 "

    method move ?(trace=true) f =
      super#move ~trace f ;
      let open Glilis in
      let pos = super#get_pos() in
      if trace
      then acc <- push_inst acc (L pos)
      else acc <- push_inst acc (M pos)

    method restore_position () =
      super#restore_position () ;
      let open Glilis in
      let pos = super#get_pos() in
      acc <- push_inst acc (M pos)

    (** Export the path as a string. *)
    method to_string () =
      BatText.to_string acc

  end

let template (w,h) s =
  let open Svg.M in
  svg
    ~a:[
      a_width (float w, Some `Px) ; a_height (float h, Some `Px) ;
      a_viewbox (0., 0., 1., 1.)
    ]
    [lineargradient ~a:[a_id "Gradient"]
       [ stop ~a:[a_offset (`Percentage 0) ; a_stopcolor "blue"] [] ;
	 stop ~a:[a_offset (`Percentage 33) ; a_stopcolor "green"] [] ;
	 stop ~a:[a_offset (`Percentage 66) ; a_stopcolor "yellow"] [] ;
	 stop ~a:[a_offset (`Percentage 100) ; a_stopcolor "red"] [] ;
       ] ;
     path
       ~a:[a_d s
	  ; a_stroke (`Icc ("#Gradient", Some (`Color ("black",None) )))
	  ; a_strokewidth (0.001, None)
	  ; a_fill `None
	  ] 
       []
    ]
