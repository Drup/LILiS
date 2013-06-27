open Calc_type

(** Contain function to evaluate arit_tree *)

(** Get the function associated to a binary operator node *)
let op2_to_fun op = match op with
    Plus -> ( +. )
  | Minus -> ( -. )
  | Times -> ( *. )
  | Div -> ( /. )
  | Pow -> ( ** )

(** Get the function associated to an unary operator node *)
let op1_to_fun op = match op with
    MinusUn -> (~-.)
  | Func func -> List.assoc func func_list


module Env = BatMap.Make(BatString)

(** Define the usual env with some usefull constant *)
let usual_env = 
  Env.Infix.(
    Env.empty 
    <-- ("pi", 4. *. atan 1.) 
    <-- ("e", exp 1.)
  )

(** eval a tree in the given env *)
let rec eval_tree env = function
    Float a -> a
  | Op2 (a1,op,a2) -> (op2_to_fun op) (eval_tree env a1) (eval_tree env a2)
  | Op1 (op , a) -> (op1_to_fun op) (eval_tree env a)
  | Id x -> Env.find x env

(** Compress a tree (aka eval part than can be evaluated) in the given env *)
let compress_tree env t = 
  (* aux function explore the tree and try to compress the place where there is no Id *)
  (* return a tuple (b,t) where b is true when the subtree t has been compressed and is just a Float node *)
  let rec aux = function
      Float a -> (true,Float a)
    | Id x -> (try (true, Float (Env.find x env)) with Not_found -> (false, Id x))
    | Op1 (op,a) -> (
	let (b,t) = aux a in
	if b then (b,Float (eval_tree usual_env (Op1 (op,t)) ) ) else (b,Op1 (op,t))
      )
    | Op2 (a1,op,a2) -> (
	let (b1,t1) = aux a1 and (b2,t2) = aux a2 in
	if b1 && b2 then (true,Float (eval_tree usual_env (Op2(t1,op,t2)) ) ) else (false,Op2 (t1,op,t2))
      )
  in snd (aux t)

