
let pi = 4. *. atan 1.

(** Extract the first element of the argument list and replace it with a default value if the list is empty *)
let get_value_arg l default = match l with
    [] -> default
  | x::_ -> x

(** Class representing a turtle *)
class turtle =
  object

    (** Position of the turtle *)
    val mutable x = 0.
    val mutable y = 0.

    method get_pos () = (x,y)

    (** Direction of the turtle *)
    val mutable direction = 0.

    (** Positions remenbered by the turtle *)
    val stack = Stack.create ()

    (** Turn the turtle by angle in degrees *)
    method turn angle =
      direction <- direction +. angle *. pi /. 180.

    (** Move the turtle by d *)
    method move ?(trace=true) d =
      x <- x +. (d *. cos direction) ;
      y <- y +. (d *. sin direction)

    (** Save the position of the turtle in the stack *)
    method save_position () =
      Stack.push (x,y,direction) stack

    (** Restore the position of the turtle from the stack. 
	@raise Empty_Stack if the stack is empty. *)
    method restore_position () = 
      let (new_x,new_y,new_dir) = Stack.pop stack in
      x <- new_x ; y <- new_y ; direction <- new_dir
      
  end

(** Translate some usual symbol of L-system into drawing order.
    @return a couple (trace, p), if trace is true, then a line to p must be traced.
*)
let draw (t : #turtle) order = match order with
  | ("+",l) -> let x = (get_value_arg l 90.) in t#turn (-.x)
  | ("-",l) -> let x = (get_value_arg l 90.) in t#turn x
  | ("F",l) -> let x = (get_value_arg l 1.) in t#move x
  | ("B",l) -> let x = (get_value_arg l 1.) in t#move (-. x)
  | ("[",_) -> t#save_position ()
  | ("]",_) -> t#restore_position ()
  | ("f",l) -> let x = (get_value_arg l 1.) in t#move ~trace:false x
  | _ -> ()

let draw_enum turtle = BatEnum.iter (draw turtle)

let draw_list turtle = BatList.iter (draw turtle)
