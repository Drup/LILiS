
let pi = 4. *. atan 1.

(** Extract the first element of the argument list and replace it with a default value if the list is empty *)
let get_value_arg l default =
  if Array.length l = 0
  then default
  else l.(0)

type pos = { mutable x : float ; mutable y : float ; mutable d : float }
let copy_pos { x ; y ; d } =
  { x ; y ; d }


type orders = [
  | `Forward
  | `forward
  | `Turn
  | `Save
  | `Restore
]

let orders = [
  "Forward", (`Forward,1) ;
  "forward", (`forward,1) ;
  "Turn"   , (`Turn,   1) ;
  "Save"   , (`Save,   0) ;
  "Restore", (`Restore,0) ;
]

class ['a] turtle =
  object(t)

    (** Position of the turtle *)
    (* We pack the position in a float record because it's (very slightly) more efficient. *)
    val pos = { x = 0. ; y = 0. ; d = 0. }

    method get_pos () = (pos.x, pos.y)

    (** Positions remenbered by the turtle *)
    val stack = Stack.create ()

    method turn angle =
      pos.d <- pos.d +. angle *. pi /. 180.

    method move ?(trace=true) f =
      pos.x <- pos.x +. (f *. cos pos.d) ;
      pos.y <- pos.y +. (f *. sin pos.d)

    method save_position () =
      Stack.push (copy_pos pos) stack

    method restore_position () =
      let { x ; y ; d } = Stack.pop stack in
      pos.x <- x ; pos.y <- y ; pos.d <- d

    method draw (order : 'a * float array) = match order with
      | `Forward, l -> t#move ~trace:true l.(0)
      | `Turn   , l -> t#turn ( -. l.(0))
      | `forward, l -> t#move ~trace:false l.(0)
      | `Save   , _ -> t#save_position ()
      | `Restore, _ -> t#restore_position ()

  end
