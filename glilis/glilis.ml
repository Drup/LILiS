open LisCommon

let pi = 4. *. atan 1.

type pos = { mutable x : float ; mutable y : float ; mutable d : float }

let copy_pos { x ; y ; d } = { x ; y ; d }

type color = { r : float ; g : float ; b : float ; a : float }

let copy_color { r ; g ; b ; a } = { r ; g ; b ; a }

type orders =
  | Forward
  | Forward'
  | Turn
  | Save
  | Restore
  | Color


let orders = [
  "Forward", (Forward, 1) ;
  "forward", (Forward',1) ;
  "Turn"   , (Turn,    1) ;
  "Save"   , (Save,    0) ;
  "Restore", (Restore, 0) ;
  "Color"  , (Color,   4) ;
]


type 'a turtle = {
  get_pos : unit -> pos ;
  get_color : unit -> color ;
  turn : float -> unit ;
  move : ?trace:bool -> float -> unit ;
  save_position : unit -> unit ;
  restore_position : unit -> unit ;
  color : color -> unit ;
  handle_lsys : (unit -> unit) -> 'a  ;
}


let transform_rhs t =
  let f order arits args = match fst @@ List.assoc order orders with
      | Forward  -> t.move ~trace:true @@ arits.(0) args
      | Turn     -> t.turn @@ -. (arits.(0) args)
      | Forward' -> t.move ~trace:false @@ arits.(0) args
      | Save     -> t.save_position ()
      | Restore  -> t.restore_position ()
      | Color    ->
          t.color { r = arits.(0) args ; g = arits.(0) args ;
                    b = arits.(0) args ; a = arits.(0) args } ;
  in f

let transform_lsys turtle lsys =
  let open Lilis in
  let transform_rule turtle rule =
    {rule with rhs = List.map ((fun (a,_) -> (transform_rhs turtle a))) rule.rhs}
  in
  { lsys with post_rules = List.map (transform_rule turtle) lsys.post_rules }

let turtle () =
  let pos = { x = 0. ; y = 0. ; d = 0. } in
  let color = ref { r = 0. ; g = 0. ; b = 0. ; a = 1. } in
  let stack = Stack.create () in

  let get_pos () = pos in
  let get_color () = !color in
  let turn angle = pos.d <- pos.d +. angle *. pi /. 180. in
  let move ?(trace=true) f =
    let d' = pos.d in
    pos.x <- pos.x +. (f *. cos d') ;
    pos.y <- pos.y +. (f *. sin d') in
  let save_position () = Stack.push (copy_pos pos, !color) stack in
  let restore_position () =
    let p, c = Stack.pop stack in
    pos.x <- p.x ; pos.y <- p.y ; pos.d <- p.d ; color := c in

  let handle_lsys f =
    color := { r = 0. ; g = 0. ; b = 0. ; a = 1. } ;
    pos.x <- 0. ; pos.y <- 0. ; pos.d <- 0. ;
    Stack.clear stack ;
    f ()
  in

  let color c = color := c in

  { get_pos ; get_color ;
    turn ; move ;
    save_position ; restore_position ;
    color ;
    handle_lsys ;
  }
