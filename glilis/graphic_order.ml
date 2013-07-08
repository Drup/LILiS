
let pi = 4. *. atan 1.

(** Extract the first element of the argument list and replace it with a default value if the list is empty *)
let get_value_arg l default = 
  if Array.length l = 0 
  then default
  else l.(0)

type pos = { mutable x : float ; mutable y : float ; mutable d : float }

(** Class representing a turtle *)
class turtle =
  object

    (** Position of the turtle *)
    (* We pack the position in a float record because it's (very slightly) more efficient. *)
    val pos = { x = 0. ; y = 0. ; d = 0. }

    method get_pos () = (pos.x, pos.y)

    (** Positions remenbered by the turtle *)
    val stack = Stack.create ()

    (** Turn the turtle by angle in degrees *)
    method turn angle =
      pos.d <- pos.d +. angle *. pi /. 180.

    (** Move the turtle by f *)
    method move ?(trace=true) f =
      pos.x <- pos.x +. (f *. cos pos.d) ;
      pos.y <- pos.y +. (f *. sin pos.d)

    (** Save the position of the turtle in the stack *)
    method save_position () =
      Stack.push (pos.x,pos.y,pos.d) stack

    (** Restore the position of the turtle from the stack. 
	@raise Empty_Stack if the stack is empty. *)
    method restore_position () = 
      let (new_x,new_y,new_dir) = Stack.pop stack in
      pos.x <- new_x ; pos.y <- new_y ; pos.d <- new_dir
      
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

let draw_enum turtle = Lilis.Lstream.iter (draw turtle)

let draw_list turtle = List.iter (draw turtle)
