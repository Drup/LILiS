
(** Extract the first element of the argument list and replace it with a default value if the list is empty *)
let get_value_arg l default = match l with
    [] -> default
  | x::_ -> x

class type turtle = object
  method turn : float -> unit
  method move : ?trace:bool -> float -> unit
  method save_position : unit -> unit
  method restore_position : unit -> unit
end

(** translate some usual symbol of L-system into drawing order *)
let draw (t : #turtle) order = match order with
  | ("+",l) -> let x = (get_value_arg l 90.) in t#turn (-.x)
  | ("-",l) -> let x = (get_value_arg l 90.) in t#turn x
  | ("F",l) -> let x = (get_value_arg l 1.) in t#move x
  | ("B",l) -> let x = (get_value_arg l 1.) in t#move (-. x)
  | ("[",_) -> t#save_position ()
  | ("]",_) -> t#restore_position ()
  | ("f",l) -> 
      let x = (get_value_arg l 1.) in 
      t#move ~trace:false x
  | _ -> ()

let draw_enum turtle = BatEnum.iter (draw turtle)

let draw_list turtle = BatList.iter (draw turtle)
