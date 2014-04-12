(** Small Arithemtic expression evaluator. *)

(** {2 Types and associated functions} *)

type op2 = Plus | Minus | Times | Div | Pow

type op1 = Func of (float -> float) | MinusUn

type 'a t =
  | Float of float
  | Op2 of ('a t) * op2 * ('a t)
  | Op1 of op1 * ('a t)
  | Var of 'a

(** {2 Environment handling} *)

exception Unknown_variable of string

(** The environment for variables *)
module Env = struct
  module M = BatMap.Make(BatString)

  type t = float M.t

  let empty = M.empty
  let add = M.add
  let mem = M.mem

  let find_arit x env = match M.Exceptionless.find x env with
    | None -> raise (Unknown_variable x)
    | Some f -> f

  let union env1 env2 = M.fold M.add env1 env2

  let of_list = List.fold_left (fun env (k,x) -> M.add k x env) M.empty

  (** Define the usual env with some usefull constants *)
  let usual =
    of_list
      [ ("pi", 4. *. atan 1.) ;
	("e", exp 1.) ;
      ]
end

(** {2 Evaluation and manipulation functions} *)

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
  | Func func -> func

(** Eval a tree with a custom f function to translated variables. *)
let rec eval_custom f = function
    Float a -> a
  | Op2 (a1,op,a2) -> (op2_to_fun op) (eval_custom f a1) (eval_custom f a2)
  | Op1 (op , a) -> (op1_to_fun op) (eval_custom f a)
  | Var x -> f x

(** Eval a tree in the given environment. *)
let eval env t =
  let f x = Env.find_arit x env in
  eval_custom f t

(* Left to right depth first traversal. *)
let rec fold f t z = match t with
  | Float _ -> z
  | Op1 (_, t) -> fold f t z
  | Op2 (t1, _, t2) -> fold f t2 (fold f t1 z)
  | Var x -> f x z

let rec bind f t = match t with
  | Float a -> Float a
  | Op1 (op,t) -> Op1 (op,bind f t)
  | Op2 (t1,op,t2) -> Op2 (bind f t1,op,bind f t2)
  | Var x -> f x

let bind_opt f t =
  let f' x = match f x with
    | None -> Var x
    | Some y -> y
  in bind f' t

let map f t = bind (fun x -> Var (f x)) t

let vars t = fold (fun x l -> x :: l) t []

(** Compress a tree (aka eval part than can be evaluated) in the given env *)
let rec compress_custom f t = match t with
  | Float a -> Float a
  | Var x -> begin match f x with
      | None -> Var x
      | Some f -> Float f
    end
  | Op1 (op,a) -> begin match compress_custom f a with
      | Float x -> Float (op1_to_fun op x)
      | t -> Op1 (op,t)
    end
  | Op2 (a1,op,a2) -> begin match compress_custom f a1, compress_custom f a2 with
      | Float x1, Float x2 -> Float (op2_to_fun op x1 x2)
      | t1, t2 -> Op2 (t1,op,t2)
    end

let compress env t =
  let f x = Env.M.Exceptionless.find x env in
  compress_custom f t

(** Return the closure of a compressed arithmetic expression. *)
let closure ?(env=Env.empty) t vars =
  let t = compress (Env.union env Env.usual) t in
  let t = map (fun x -> List.assoc x vars) t in
  (function env -> eval_custom env t)
