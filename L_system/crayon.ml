open Cairo

exception Empty_stack
exception Not_image

let pi = 4. *. atan 1. 


(** Cairo implementation of the turtle *)


(** Type of Cairo contexte *)
type context = 
	Picture of float * float
	| Gtk of GMisc.drawing_area

(** initialize cairo context *)
let init_context draw_ctx = match draw_ctx with
	  Picture (x,y) -> (
		let surface = Cairo.image_surface_create Cairo.FORMAT_ARGB32 (1 + int_of_float x) (1 + int_of_float y) in
		let ctx = Cairo.create surface in
		Cairo.scale ctx x y ;
		Cairo.set_antialias ctx Cairo.ANTIALIAS_SUBPIXEL ;
		Cairo.set_line_width ctx (1. /. (max x y) ) ; 
		ctx
		)
	| Gtk w-> (
		let ctx = Cairo_lablgtk.create w#misc#window in
		let { Gtk.width = x ; Gtk.height = y } = w#misc#allocation in
		Cairo.scale ctx (float x) (float y) ;
		Cairo.set_antialias ctx Cairo.ANTIALIAS_SUBPIXEL ;
		Cairo.set_line_width ctx (1. /. (float (max x y)) ) ; 
		ctx
		)



(** Class representing a turtle, take a Cairo context in argument *)
class turtle ctx = object

	(** Position of the turtle *)
	val mutable x = 0.
	val mutable y = 0.
	
	(** Direction of the turtle *)
	val mutable direction = 0.
	
	(** Set if the turtle trace a line when she move *)
	val mutable trace = true
	
	(** Positions remenbered by the turtle *)
	val mutable stack = []
	
	(** Cairo context where the Turtle draw *)
	val context = init_context ctx
	
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
		if trace then line_to context x y else move_to context x y

	(** Save the position of the turtle in the stack *)
	method save_position () = 
		stack <- (x,y,direction,trace)::stack
	
	(** Restore the position of the turtle from the stack, raise Empty_Stack if the stack is empty *)
	method restore_position () = match stack with
		  [] -> raise Empty_stack
		| (new_x,new_y,new_dir,new_trace)::t -> (
			move_to context new_x new_y ; 
			stack <- t ;
			x <- new_x ; y <- new_y ; direction <- new_dir ; trace <- new_trace
			)
	
	(** Apply drawing on the surface *)
	method draw () = stroke context
	
	(** Draw to a png, raise *)
	method write file = match surface_get_type (get_target context) with
		`Image -> Cairo_png.surface_write_to_file (get_target context) file
		| _ -> raise Not_image
	
end

