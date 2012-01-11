exception Empty_stack
exception Not_image

let pi = 4. *. atan 1.


(** Cairo implementation of the turtle *)


(** Type of Cairo contexte *)
type context =
	Picture of int * int
	| Gtk of GMisc.drawing_area

let get_coord = function Picture(x,y) -> (x,y) | Gtk w -> let { Gtk.width = x ; Gtk.height = y } = w#misc#allocation in (x,y)

(** initialize cairo context *)
let init_context draw_ctx = match draw_ctx with
	  Picture (x,y) -> (
		let surface = Cairo.Image.create Cairo.Image.ARGB32 x y in
		let ctx = Cairo.create surface in
(*		subpixel antialias is currently not suported by Cairo.PNG *)
(*		Cairo.set_antialias ctx Cairo.ANTIALIAS_SUBPIXEL ;*)
		Cairo.set_line_width ctx 1. ;
		ctx,x,y,surface
		)
	| Gtk w-> (
		let ctx = Cairo_gtk.create w#misc#window in
		let { Gtk.width = x ; Gtk.height = y } = w#misc#allocation in
(*		subpixel antialias is currently not suported by Cairo.PNG *)
(*		Cairo.set_antialias ctx Cairo.ANTIALIAS_SUBPIXEL ;*)
		Cairo.set_line_width ctx 1. ;
		ctx,x,y,(Cairo.get_target ctx)
		)



(** Class representing a turtle, take a Cairo context in argument *)
class turtle ctx =

	let c,sx,sy,s = init_context ctx in

	object

	(** Position of the turtle *)
	val mutable x = 0.
	val mutable y = 0.

	(** Direction of the turtle *)
	val mutable direction = 0.

	(** Set if the turtle trace a line when she move *)
	val mutable trace = true

	(** Positions remenbered by the turtle *)
	val mutable stack = []

	(** Cairo context and surcae where the Turtle draw *)
	val context = c
	val surface = s

	(** Size of the picture *)
	val size_x = float sx
	val size_y = float sy

	(** Turn the turtle by angle in degrees *)
	method turn angle =
		direction <- direction +. angle *. pi /. 180.

	(** Set trace mode *)
	method set_trace b =
		trace <- b

	(** Move the turtle by d *)
	method move d =
		x <- x +. (d *. cos direction) ;
		y <- y +. (d *. sin direction) ;
		if trace
			then Cairo.line_to context (floor (size_x *. x)) (floor (size_y *. y))
			else Cairo.move_to context (floor (size_x *. x)) (floor (size_y *. y))

	(** Save the position of the turtle in the stack *)
	method save_position () =
		stack <- (x,y,direction,trace)::stack

	(** Restore the position of the turtle from the stack, raise Empty_Stack if the stack is empty *)
	method restore_position () = match stack with
		  [] -> raise Empty_stack
		| (new_x,new_y,new_dir,new_trace)::t -> (
			Cairo.move_to context new_x new_y ;
			stack <- t ;
			x <- new_x ; y <- new_y ; direction <- new_dir ; trace <- new_trace
			)

	(** Fill the picture with solid white and set the color to solid black *)
	method fill () =
		Cairo.set_source_rgb context 1. 1. 1.;
		Cairo.paint context ~alpha:1.;
		Cairo.set_source_rgba context 0. 0. 0. 1. ;

	(** Apply drawing on the surface *)
	method draw () = Cairo.stroke context ; Cairo.move_to context (floor (size_x *. x)) (floor (size_y *. y))

	(** Draw to a png, raise *)
	method write file =
		Cairo.PNG.write surface file ;
		Cairo.Surface.finish (Cairo.get_target context) ;


end
