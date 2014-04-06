
type path_inst =
  | M of Glilis.pos
  | Mr of Glilis.pos
  | L of Glilis.pos
  | Lr of Glilis.pos

let push_inst buf =
  let foo buf s x y =
    Buffer.add_string buf s ;
    Buffer.add_string buf (string_of_float x) ;
    Buffer.add_string buf " " ;
    Buffer.add_string buf (string_of_float y) ;
  in let open Glilis in function
    | M  { x ; y } -> foo buf " M " x y
    | Mr { x ; y } -> foo buf " m " x y
    | L  { x ; y } -> foo buf " L " x y
    | Lr { x ; y } -> foo buf " l " x y

class ['a] svg_turtle =

  object inherit ['a] Glilis.vturtle as super

    val acc =
      (* Whatever the initial size, we're going to blow it up anyway.
         Experimentally, the initial size doesn't affect performances. *)
      let buf = Buffer.create 10 in
      Buffer.add_string buf "M 0 0" ;
      buf

    method move ?(trace=true) f =
      super#move ~trace f ;
      let open Glilis in
      let pos = super#get_pos in
      if trace
      then push_inst acc (L pos)
      else push_inst acc (M pos)

    method restore_position () =
      super#restore_position () ;
      let open Glilis in
      let pos = super#get_pos in
      push_inst acc (M pos)

    method color c = ()

    (** Export the path as a string. *)
    method to_string () =
      Buffer.contents acc

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
