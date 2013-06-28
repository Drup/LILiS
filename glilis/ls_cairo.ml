exception Empty_stack
exception Not_image

let pi = 4. *. atan 1.


(** Cairo implementation of the turtle *)


(** Class representing a turtle *)
class turtle size_x size_y context surface =
  object

    (** Position of the turtle *)
    val mutable x = 0.
    val mutable y = 0.

    (** Direction of the turtle *)
    val mutable direction = 0.

    (** Positions remenbered by the turtle *)
    val mutable stack = []

    (** Turn the turtle by angle in degrees *)
    method turn angle =
      direction <- direction +. angle *. pi /. 180.

    (** Move the turtle by d *)
    (* We do the scaling and the rounding by ourself here because cairo do it too slowly *)
    method move ?(trace=true) d =
      x <- x +. (d *. cos direction) ;
      y <- y +. (d *. sin direction) ;
      if trace
      then (
	Cairo.line_to context (floor (size_x *. x)) (floor (size_y *. y)) ;
	Cairo.stroke context
      ) ;
      Cairo.move_to context (floor (size_x *. x)) (floor (size_y *. y))

    (** Save the position of the turtle in the stack *)
    method save_position () =
      stack <- (x,y,direction)::stack

    (** Restore the position of the turtle from the stack, raise Empty_Stack if the stack is empty *)
    method restore_position () = match stack with
	[] -> raise Empty_stack
      | (new_x,new_y,new_dir)::t -> (
	  Cairo.move_to context (floor (size_x *. new_x)) (floor (size_y *. new_y)) ;
	  stack <- t ;
	  x <- new_x ; y <- new_y ; direction <- new_dir
	)

    (** Fill the picture with solid white and set the color to solid black *)
    method fill () =
      Cairo.set_source_rgb context 1. 1. 1.;
      Cairo.paint context ~alpha:1.;
      Cairo.set_source_rgba context 0. 0. 0. 1.

    (** Apply drawing on the surface *)
    method draw () = Cairo.stroke context ; Cairo.move_to context (floor (size_x *. x)) (floor (size_y *. y))

  end
  
(** A turtle that write to a png file *)
class png_turtle size_x size_y = 
  
  let surface = Cairo.Image.create Cairo.Image.ARGB32 size_x size_y in
  let ctx = Cairo.create surface in
  let _ = Cairo.set_line_width ctx 1. in
  
  object inherit turtle (float size_x) (float size_y) ctx surface
	
    (** Draw to a png *)
    method write file =
      Cairo.PNG.write surface file

  end

(** A turtle that write on a gtk surface *)
class gtk_turtle w =
  let ctx = Cairo_gtk.create w#misc#window in
  let { Gtk.width = size_x ; Gtk.height = size_y } = w#misc#allocation in
  let surface = Cairo.get_target ctx in
  let _ = Cairo.set_line_width ctx 1. in
  
  object inherit turtle (float size_x) (float size_y) ctx surface

  end 
