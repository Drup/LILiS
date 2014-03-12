

(* On Thu, 2013-10-03 at 23:41 +0100, Jeremy Yallop wrote:

   I think it's of general interest.  I wouldn't worry about the length;
   > longer posts are welcome.
   >
   > Kind regards,
   >
   > Jeremy.
   >
   >   note: the entire post is in ocaml comments.  Included code runs in
   the top-level. Edit - Select All - Copy - Paste has to go through
program editor, pasting directly does not work ...

   If I may, I want to take one step back, before the post modularizing
   streams, and show some benchmark results for streams.  At the same time
   I would like to include some thoughts as to where I would like to go
   with this: Make a, if minor, contribution to OCAML by providing a
   library of streams.  All these (dozens of) streams must have identical
   signatures and, obviously, identical semantics for the the values in the
   signatures.  They differ in speed and resource usage.  The plain list is
   the fastest construct for traversing sequential data, given that lists
   are not big.  If we have a mere 100 million char list we are already in
   serious trouble processing it on a laptop, or, heavens forbid, a tablet.
   In a polymorphic list each character takes 3 words (if the list is
   'pure', i.e.: does not contain other lists, or even just a null other
   than ( [] ); else it takes 5). With streams we can balance better.  The
   small sample below will show where I want to go.  How to code the
   streams is a fairly simple matter, testing takes time, but I know how to
do it.  Packaging it in an elegant way is currently below my capacity.
*)

let globalEltNulChr = '?'
type streamNames = [ `Std_Stream | `ListStream |`PackStream |
                     `ConsStream
                   | `LazyStream | `LazyStrm20  ]
exception Empty

(* The signature for all streams has type 'a t.  Below is a 'Toy'
   signature we need to run some tests.  Streams that are to be used in
   real live have to interact with user types, via some '  ... with type
   xyz = Streams.t   Ignore this for the moment *)

module type EltSig = sig
  type 'a t
  val int2Gen : string -> ( int -> 'a t )
  val int2Gen' : string -> ( int -> 'a t option )
  val elt2Chr : 'a t -> char
  val chr2Elt : char -> 'a t
  val eltNull : 'a t
end

module Elt:EltSig = struct
  type 'a t = char
  let int2Gen data i =
    if i < String.length data then String.unsafe_get data i
    else raise Empty
  let int2Gen' data i = if i < String.length data then Some data.[i]
    else None
  let elt2Chr elt = elt
  let chr2Elt elt = elt
  let eltNull = globalEltNulChr
end

(* Tentative signature.  Mostly self-explanatory. Uses foo for
   generators that use exception Empty and foo' for those that use
   Some/None.  The standard Stream uses peek, when wrapped it is aliased to
   head'. *)

module type StreamSig = sig
  type 'a t                                   (*  ALIASES for val *)
  val name : streamNames
  val null : 'a t
  val head : 'a t -> 'a
  val head' : 'a t -> 'a option               (* peek *)
  val cons : 'a -> 'a t -> 'a t               (* push *)
  val tail : 'a t -> 'a t                     (* next junk pop *)
  val join : 'a t -> 'a t -> 'a t             (* cat append *)
  val iter : ('a -> unit) -> 'a t -> unit
  val fold : ('a -> 'b -> 'a) -> 'a -> 'b t -> 'a (* fold_left *)
  val from : ( int -> 'a ) -> 'a t
  val from' : ( int -> 'a option) -> 'a t
  val empty : 'a t -> bool
  val count : 'a t -> int                       (* pos *)
  val of_list : 'a list -> 'a t
  val of_string : string -> char t
  (* val bits : mask -> 'a t -> int            (* int from packed bits *)
     val pack : mask -> int -> 'a t      (* pack int into packed bits *)

     item (singleton) word open close down back reverse find
  *)
end

(* This is from
   http://okmij.org/ftp/ML/first-class-modules/existentials.ml
   That post inspired me to start this. (I want to use regular expressions,
   automatons, over sequences of objects that support some (integer-) edge
   function, not merely equality. First class modules will do the trick and
   are fast enough that the implementation is more than a toy).

   The code below (Russo's paper is not yet used; but, eventually some of
   the above signatures go in here, especially:

   constructors (of_list / _string / _array / _bigArray etc)
   null (because not all streams have nulls)
   join (append for streams that do not have identical implementations)
   the usual suspects 'fold_right', 'assoc', etc etc (that are not
   implemented individually for each stream.)
*)

module type Streams = sig   (* abstract the type of streams ('t') . *)
  type elt           (* NOT the same as EltSig.elt; suggestive only *)
  include StreamSig
  val stream : elt t
end
type 'a stream = (module Streams with type elt = 'a)


(* The first example is a wrapper of the Standard stream.  The fold
   function could be implemented generically, lets say, for the moment, in
   the test module. The benchmarks show that there is a significant slow
   down in doing that. (Doing it by wrapping packed modules does not help.)
   This stream is the fastest of all, because it uses
   'a { mutable foo:... mutable bar: ... } as type.
   More about this in the list wrapper *)

module StdStream:StreamSig = struct     (* elt2Gen must raise Empty *)
  open Stream
  type 'a t = 'a Stream.t
  let name = `Std_Stream
  let null = sempty
  let count = Stream.count
  let empty t = t = sempty
  let rec fold f acc t =
    let rec aux acc = match peek t with
      | Some h -> junk t; fold f (f acc h) t
      | None -> acc in aux acc
  let tail t = Stream.junk t; t
  let cons _ = assert false
  let head' = Stream.peek
  let head t = match Stream.peek t with Some h -> h
                                      | None -> raise Empty
  let from' = Stream.from
  let from t = assert false
  let join _ = assert false
  let of_string = Stream.of_string
  let of_list = Stream.of_list
  let iter = Stream.iter
end

(* The list module provides all functions needed for our signature (and
   a lot more).  It has about the same speed as the modules below,
   because the benchmark includes the creation (via String.explode).
   For smallish lists it is ideal; for huge ones not. Problem:
   OCAML has a nice syntax for lists which we loose by wrapping it;
   but the OCAML community has found many ways to get around syntax
   problems.  This wrapping costs nothing (other than convenience).
*)
module ListStream:StreamSig = struct (* elt2Gen must raise Empty *)
  type 'a t = 'a list
  let name = `ListStream
  let null = []
  let count = List.length
  let empty t = if t = [] then true else false
  let fold = List.fold_left
  let join t1 t2 = t1 @ t2
  let tail = List.tl
  let iter = List.iter
  let cons h t = h :: t
  let head  = List.hd
  let head' t = if t = [] then None else Some (List.hd t)
  (* A libray should not have 'assert false' statements that can be
     encountered in usage. There seem to be ways to restrict the
     signature of a module, but it needs trickery to make those
     compatible with the larger signature.  Hopefully GADTs will do the
     trick.
  *)
  let from _ = assert false
  let from' _ = assert false
  let of_list l = l
  let of_string s = assert false
end

(* This stream is a simple variant of the lazy one shown next.
   Downsides:
   - there is no null - type. (Well, there is a hacked one)
   - It uses 4 words per cell; instead of 3 for lazy or lists cells.
   Upsides:
   - It is much faster then a lazy cell, because closures are fast.
   - The extra cell is in effect a position indicator.
*)

module ConsStream:StreamSig  = struct
  type 'a t = Cons of 'a * (int -> 'a t) * int
  let name = `ConsStream
  let null = Cons( Obj.magic Elt.eltNull,
      (fun _ -> assert false), max_int )
  (* Null is ONLY used in the form t == null; returned but NEVER
     matched; Obj.magic has to come out, eventually, probably by defining a
     module Null of correct type in Streams.  As is, the only obvious, but
     not free, way that I can see, is to change the type to
     Cons of 'a option  * (int -> 'a t) * int

     Better: to move null to the enclosing module type streams; or
     include signature of Elt (If modules are left as stand-alone)
  *)

  let empty t = t == null
  let tail t = if empty t then t       (* return tail or null; never
                                          fail *)
    else match t with (Cons (_, fnT, pos )) ->
      try fnT pos with Empty -> null

  let head t = if t == null then raise Empty
    else match t with (Cons (h, _, _)) -> h
  let head' t = if t == null then None
    else match t with (Cons (h, _, _)) -> Some h
  let cons h t = Cons(h, (fun _ -> t), -1)
  let from f = let rec mk n = Cons (f n, mk, succ n) in mk 0

  let iter f t = if t == null then raise Empty else
      let rec aux f ((Cons (h, fnT, pos))) = f h; aux f (fnT pos) in
      try aux f t with Empty -> ()

  let fold f acc t = if t == null then raise Empty else
      let rec aux a = function (Cons (h, fnT, pos)) as t ->
        if t == null then a else aux (f a h) (tail t)
      in aux acc t

  let join s1 s2 =
    if s1 == null then s2 else match s1 with (Cons(h, fn, p)) ->
      let rec aux h1 p1 =
        try match fn p1 with (Cons(h2, _, p2)) -> Cons( h1, aux h2, p2 )
        with Empty                             -> cons h1 s2 in
      aux h p
  let count t = if t == null then ( -1)
    else match t with (Cons (_, f, pos)) -> pos
  let of_list t = assert false
  let of_string s = assert false
  let from' _ = assert false
end

(* An implementation of streams as cons cells with lazy tails *)
(* This is the stream demonstrated by Claudio Russo. (Google above head
   line). It gave me the idea that by packaging streams into modules a wide
   variety of streams could co-exists and interact with each other in a
   very efficient way.  As it turns out lazy lists are very much slower;
   but lazyness is sometimes needed.  *)

module LazyStream : StreamSig = struct
  type 'a t = Cons of 'a * 'a t Lazy.t
  let name = `LazyStream
  let null = Cons( Obj.magic Elt.eltNull, Obj.magic (fun _ -> assert
        false))
  (* see ConsStream for comment about Obj.magic *)
  let empty t = t == null
  let head (Cons (h, _)) = h
  let tail (Cons (_, lazy t)) = t
  let from' f =
    let rec mk n = match f n with
      | Some h -> Cons (h, lazy (mk (n + 1)))
      | None -> null
    in mk 0
  let rec iter f t = match t with (Cons( h, tt)) ->
    if t == null then () else iter f ((f h); (Lazy.force tt))
  let rec fold f acc t = match t with (Cons( h, tt)) ->
    if t == null then acc else fold f (f acc h) (Lazy.force tt)
  let count _ = assert false let of_string _ = assert false
  let of_list _ = assert false
  let from _ = assert false let join _ = assert false
  let cons _ = assert false let head' _ = assert false
end

module LazyStrm20 : StreamSig = struct
  (* see benchmarks at the end for comments about speed of lazy *)

  type 'a t = Cons of 'a * 'a t Lazy.t
  let name = `LazyStrm20
  let null = Cons( Obj.magic Elt.eltNull,
      Obj.magic (fun _ -> assert false))
  (* see ConsStream for comment about Obj.magic *)

  let empty t = t == null
  let head t = if t == null then raise Empty else match t with
        (Cons (h, _)) -> h
  let tail t = if t == null then t else match t with
        (Cons (_, t)) -> Lazy.force t
  let from' f = (* 30% improvement over LazyStream; still sluggish *)
    let rec mk n =
      let rec aux m n =
        if m = 1 then match f n with
          | Some h -> Cons (h, lazy (mk (n + 1)))
          | None -> null
        else match f n with
          | Some h -> Cons (h, Lazy.from_val (aux (m - 1) (n + 1)))
          | None -> null
      in aux 20 n
    in mk 0
  let rec iter f t = match t with (Cons( h, tt)) ->
    if t == null then () else iter f ((f h); tail t)
  let rec fold f acc t = match t with (Cons( h, tt)) ->
    if t == null then acc else fold f (f acc h) (tail t)
  let count _ = assert false let of_string _ = assert false
  let of_list _ = assert false
  let from _ = assert false let join _ = assert false
  let cons _ = assert false let head' _ = assert false
end


(*  *******************      Tests   ***********************     *)

let name = function `Std_Stream -> "Std"
                  | `ListStream -> "List"
                  |`PackStream -> "Pack"  | `ConsStream -> "Cons"
                  | `LazyStream -> "Lazy" | `LazyStrm20 -> "Lz20"
open Printf

module Test = functor (E:EltSig) -> functor (S:StreamSig) ->
  functor (T:sig val tsize:int end) -> struct
    let explode str = let accu = ref [] in
      for i = (pred (String.length str)) downto 0
      do accu := E.chr2Elt(String.unsafe_get str i) :: !accu done; !accu
    let str = String.make (T.tsize - 1) 'x' ^ "Q"
    let tsize = T.tsize
    let name = name S.name
    let t() = if S.name = `Std_Stream then S.from' (E.int2Gen' str)
      else if  S.name = `ListStream then
        S.of_list (explode str)
      else if (S.name = `LazyStream)
           || (S.name = `LazyStrm20)
      then S.from' (E.int2Gen' str)
      else S.from (E.int2Gen str)
    (* BENCHMARK FUNCTIONS *)
    let iter () = let count = ref 0 in
      S.iter (fun _ -> incr count) (t()); assert (!count = tsize)

    let consume () =  let count = ref 0 in
      let rec aux stm =
        if S.empty stm then !count else aux (S.tail stm) in
      assert( !count = aux (t()) )

    let fold () =  let count = ref 0 in
      let res = ( S.fold (fun n x -> incr count; succ n)) 0 (t()) in
      assert (res = !count)
  end

let its = 1_000_000

module TStd = Test(Elt)(StdStream)(struct let tsize = its end)
let lsCons _ = TStd.consume() let lsFold _ = TStd.fold()
let lsIter _ = TStd.iter()

module TLazy = Test(Elt)(LazyStream)(struct let tsize = its end)
let lzCons _ = TLazy.consume() let lzFold _ = TLazy.fold()
let lzIter _ = TLazy.iter()

module TLzy2 = Test(Elt)(LazyStrm20)(struct let tsize = its end)
let l2Cons _ = TLzy2.consume() let l2Fold _ = TLzy2.fold()
let l2Iter _ = TLzy2.iter()

module TCons = Test(Elt)(ConsStream)(struct let tsize = its end)
let tcCons _ = TCons.consume() let tcFold _ = TCons.fold()
let tcIter _ = TCons.iter()

module TList = Test(Elt)(ListStream)(struct let tsize = its end)
let tlCons = TList.fold() let tlFold = TList.consume()
let tlIter = TList.iter()

let no_op n =  (* Base line for banchmark; no meaningfull stream is
                  faster *)
  let rec aux n = function
    | accu when n > 0 -> aux (pred n) accu
    | accu -> accu
  in ignore (aux n (0,0))

let what = (* useless list for timing cList below *)
  let accu = ref [] in for i = (pred its) downto 0
  do accu := 'x' :: !accu done; !accu

let cList n =  (* consume list *)
  let rec aux = function | h :: t -> aux t | [] -> ()
  in aux what

open Benchmark      (* http://www.bagley.org/~doug/ocaml/ *)
(* benchmark.ml is a single self-contained source module *)
let () =
  let res = throughputN ~repeat:1 1
      [(TLazy.name ^ ".cons", lzCons, its);
       (TLazy.name ^ ".fold", lzFold, its);
       (TLazy.name ^ ".iter", lzIter, its);
       (TLzy2.name ^ ".cons", l2Cons, its);
       (TLzy2.name ^ ".fold", l2Fold, its);
       (TLzy2.name ^ ".iter", l2Iter, its);
       (TStd.name ^ ".cons", tcCons, its);
       (TStd.name ^ ".fold", tcFold, its);
       (TStd.name ^ ".iter", tcIter, its);
       (TCons.name ^ ".cons", tcCons, its);
       (TCons.name ^ ".fold", tcFold, its);
       (TCons.name ^ ".iter", tcIter, its);
       (TList.name ^ ".cons", tcCons, its);
       (TList.name ^ ".fold", tcFold, its);
       (TList.name ^ ".iter", tcIter, its);
       (             "no_op", no_op , its);  (* NOT STREAMS *)
       (             "cList", cList , its);  (* for comparison only *)
      ] in
  tabulate res

(*
Ways to create fast streams and how to avoid lazy ones.

  This is the real subject of this post with some tentative conclusions.
  Comments about the benchmark;
  1168/s means 1168 calls were executed in 1 second with
its = 1_000_000 iterations. This number is for the base line above;
doing empty iterations. For my aging dell with 4666 Bogomips (2.6 MH)
that means something like 2 to 3 instr per clock cycle.
Looking at the assembler code suggests, 4 instructions are executed.
(Pretty awesome compilation! )

.globl camlDink__aux_1450
camlDink__aux_1450:
.loc 1 317
.cfi_startproc
.L3209:
cmpq $1, %rax
jle .L3208
addq $-2, %rax
jmp .L3209
.align 4

The no-op is so fast that we can dispense with calibrating
(subtracting the time for empty loop in the benchmark procedure).
Assuming 2.6 (clock) cycles / second we have need approx. 130 cycles for
evaluating a lazy.

Since lazy streams are very desirable things to have, I was searching
for ways to sweeten the timings a bit.  Using Lazy.from_val helps just a
bit.  But lazy_from_value is not really lazy, it only allows me to call
a function without using Lazy.force, i.e.: in an eager way. Thus there
is a loop that builds 20 cells eagerly and then returns with a lazy
value. (I am missing something here, it should really be faster.
  Forcing a value causes no real slow-down, so the code of iter, etc,
should be ok. ...? )
Maybe it would be more productive to simply built short lists each
  time and use a hack to append these. (Batteries does that for
reverse_append.)
I do not have a clear understanding of the Lazy code involved; it
involves calling an assembler module outside Ocaml, which in turn calls
a memory allocation inside OCAML (for reasons relating to the garbage
collector).  It seems prudent not to expect any fundamental improvement
here and to concentrate on ways to avoid calling lazy functions very
frequently.

module ConsStream:StreamSig  = struct
type 'a t = Cons of 'a * (int -> 'a t) * int

provides a way of 'simulating' lazyness with a closure.  If we avoid
cons-ing very often we now have a persistent stream about as fast as the
(destructive) standard stream.  Moreover, as an indexed stream, we can
  choose any suitable data structure for the index function: Arrays; Big
Arrays; Strings.
Also, the new 4.01 features: PR#5771: Add primitives for reading 2, 4,
8 bytes in strings and bigarrays (Pierre Chambart) could probably help a
lot.

Indexed Streams can be coded in a way that provides (near) instant
reversal, since all the data resides in arrays or strings.  I have coded
some of these things, but they need serious testing (The one thing the
OCAML type checker is powerless against: one off errors...).

Timing for consume / fold / iterate for various types
Lazy.cons 7.34/s        --   7.34 * 2,6 Cycles / instruction = 130
Lazy.fold 7.84/s        7%   Note: approx 8 million chars / sec
                    Lazy.iter 7.92/s        8%
Lz20.cons 10.1/s       38%   Use Lazy.from_val 20 times; then lazy ...
Lazy.force is very fast for already forced values.
Lz20.fold 10.3/s       40%
Lz20.iter 10.5/s       43%
Std.cons 36.5/s      398%  Standard (destructive) stream.  Base line.
List.cons 36.6/s      399%
Cons.cons 37.6/s      413%  Cons of 'a * (int -> 'a t) * int
Std.fold 50.5/s       588%
Cons.fold 50.9/s      594%
List.fold 51.9/s      607%
Std.iter 63.3/s       762%  Standard stream, internal iterator
Cons.iter 63.3/s      762%
List.iter 63.3/s      762%  includes: S.of_list (explode str)
no_op 1168/s    15812%

minor variations between runs are expected ...
Lazy.cons 5.71/s        --
Lazy.fold 6.09/s        7%
Lazy.iter 6.19/s        8%
Lz20.fold 8.41/s       47%
Lz20.cons 8.49/s       49%
Lz20.iter 8.49/s       49%
Cons.cons 36.7/s      542%
List.cons 37.4/s      554%
Std.cons 37.5/s       556%
Cons.fold 50.9/s      791%
Std.fold 51.9/s       808%
List.fold 52.4/s      817%
Cons.iter 62.2/s      988%
List.iter 62.7/s      998%
Std.iter 63.6/s      1014%
cList  217/s     3702%  Consuming a already exploded list
no_op 1168/s    20337%

Claudio Russo has used the example of the Sieve of prime numbers as a
stream that could be implemented as a module.  I can imagine a large
part of daily programming activities that fit the stream paradigm:
   -    Any sequence, with and without positioning and/or position
information.
   -    Trees; simply because the (polymorphic) type of a stream can
obviously include other streams.
   -    Suffix tries.  (Consing builds the trie).  (find operation to
   search for suffixes, substrings) (tail to return them all)
   -    Association lists.
   -    Sets, Bags
   - Database access (internal or external; effortlessly
interchangeable)
- etc etc

The trick will be to use GADTs to create the streams.  It is at that
level that anything not in the signature causes a typing error.  Thus we
can have an large signature with most streams 'implementing' them as
(assert false), which would become acceptable as these are never
reached.

If anybody would like some benchmarks along these lines, I would be
happy to provide them.  Speed is far from everything... But sometimes
it's nice to play around with that. (Why are there still more
C-programmers than OCAML ones; ok; don't answer that)

NEXT: same thing packaged as first class modules (but no GADTs yet)

Peter Frey

PS: I saw just noticed a post with attachments.  I did not know this
would be acceptable. Would they be archived? (They don't have to be,
since more finished code should probably go on OCAML-forge.  I have have
never done that so far.)
*)
