(** Optimization passes on L-systems. *)

val constant_folding :
  ('a * string Calc.t list) Lilis.lsystem -> ('a * string Calc.t list) Lilis.lsystem
(** A symbol is considered a constant when it's not used in any of the main rules of a L-system.
    This pass merges consecutive constant symbols into a unique symbol and add post rules for each of these new symbols.
    The new post rule is created by merging the post rules of the folded symbols. The rules of the folded symbols are pre-applied to their arguments and only free variables are kept.

    For exemple, let's consider the L-system featuring the following rules:
    {v
rule A(x) = X Y(3*x, 2*x) A(x-1) F(2) Z
post rule X = Turn(60)
post rule Y(x,y) = Forward (x+y)
post rule F(l) = Forward(l)
    v}

    We will create two new rules for [X+Y] and [X+Z]. [Z] doesn't have any post rules so it doesn't contribute to the new post rule. Since only [x] appears in [X Y(3*x, 2*x)], the new post rule will only have one argument. Here is the resulting L-system:

    {v
rule A(x) = X+Y(x) A(x-1) F+Z
post rule X = Turn(60)
post rule Y(x,y) = Forward (x+y)
post rule F(l) = Forward(l)
post rule X+Y(x) = Turn(60) Forward (3*x+2*x)
post rule F+Z = Forward(2)
    v}
*)

val compress_calcs : ?env:Calc.Env.t ->
  ('a * string Calc.t list) Lilis.lsystem -> ('a * string Calc.t list) Lilis.lsystem
(** Apply {! Calc.compress } to every arithmetic expressions. *)
