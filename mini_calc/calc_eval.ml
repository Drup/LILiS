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

(** Eval a tree with a custom f function to translated variables. *)
let rec eval_tree_custom f = function
    Float a -> a
  | Op2 (a1,op,a2) -> (op2_to_fun op) (eval_tree_custom f a1) (eval_tree_custom f a2)
  | Op1 (op , a) -> (op1_to_fun op) (eval_tree_custom f a)
  | Id x -> f x

(** Eval a tree in the given environment. *)
let eval_tree env t = 
  let f x = Env.find_arit x env in
  eval_tree_custom f t

let rec map_tree f t = match t with
  | Float a -> Float a
  | Op1 (op,t) -> Op1 (op,map_tree f t)
  | Op2 (t1,op,t2) -> Op2 (map_tree f t1,op,map_tree f t2)
  | Id x -> Id (f x)

let get_vars t =
  let rec aux acc = function
    | Float _ -> acc
    | Op1 (_ , t) -> aux acc t
    | Op2 (t1 , _ , t2) -> let acc = aux acc t1 in aux acc t2 
    | Id x -> x :: acc
  in aux [] t

(** Compress a tree (aka eval part than can be evaluated) in the given env *)
let rec compress_tree_custom f t = match t with
  | Float a -> Float a
  | Id x -> begin match f x with
      | None -> Id x
      | Some f -> Float f
    end
  | Op1 (op,a) -> begin match compress_tree_custom f a with
      | Float x -> Float (op1_to_fun op x)
      | t -> Op1 (op,t)
    end
  | Op2 (a1,op,a2) -> begin match compress_tree_custom f a1, compress_tree_custom f a2 with
      | Float x1, Float x2 -> Float (op2_to_fun op x1 x2)
      | t1, t2 -> Op2 (t1,op,t2)
    end

let compress_tree env t = 
  let f x = Env.Exceptionless.find x env in
  compress_tree_custom f t
