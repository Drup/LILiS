
let pi = 4. *. atan 1.

type pos = { mutable x : float ; mutable y : float ; mutable d : float }

let copy_pos { x ; y ; d } = { x ; y ; d }

type color = { r : float ; g : float ; b : float ; a : float }

let copy_color { r ; g ; b ; a } = { r ; g ; b ; a }

type orders = [
  | `Forward
  | `forward
  | `Turn
  | `Save
  | `Restore
  | `Color
]

let orders = [
  "Forward", (`Forward,1) ;
  "forward", (`forward,1) ;
  "Turn"   , (`Turn,   1) ;
  "Save"   , (`Save,   0) ;
  "Restore", (`Restore,0) ;
  "Color"  , (`Color,  4) ;
]


class type ['a] turtle = object
  constraint 'a = [< orders ]
  method get_pos : pos
  method get_color : color
  method turn : float -> unit
  method move : ?trace:bool -> float -> unit
  method save_position : unit -> unit
  method restore_position : unit -> unit
  method color : color -> unit
  method draw : 'a * float array -> unit
end

class virtual ['a] vturtle =
  object(t)

    (** Position of the turtle *)
    (* We pack the position in a float record because it's (very slightly) more efficient. *)
    val mutable pos = { x = 0. ; y = 0. ; d = 0. }

    val mutable color = { r = 0. ; g = 0. ; b = 0. ; a = 1. }

    method get_pos = pos

    method get_color = color

    (** Positions remenbered by the turtle *)
    val stack = Stack.create ()

    method turn angle =
      pos.d <- pos.d +. angle *. pi /. 180.

    method move ?(trace=true) f =
      let d' = pos.d in
      pos.x <- pos.x +. (f *. cos d') ;
      pos.y <- pos.y +. (f *. sin d')

    method save_position () =
      Stack.push (copy_pos pos, copy_color color) stack

    method restore_position () =
      let p, c = Stack.pop stack in
      pos <- p ; color <- c

    method color c =
      color <- c

    method draw (order : 'a * float array) = match order with
      | `Forward, l -> t#move ~trace:true l.(0)
      | `Turn   , l -> t#turn ( -. l.(0))
      | `forward, l -> t#move ~trace:false l.(0)
      | `Save   , _ -> t#save_position ()
      | `Restore, _ -> t#restore_position ()
      | `Color  , l -> t#color { r =l.(0) ; g = l.(1) ; b = l.(2) ; a = l.(3) }

  end
