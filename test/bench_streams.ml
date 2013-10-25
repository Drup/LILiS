open Benchmark
open Lilis

module BeSequence = Engine(Stream.Sequence)
module BeSeq = Engine(Stream.Seq)
module BeEnum = Engine(Stream.Enum)
(* module BeStream = Engine(Stream.Stream) *)
module BeLazyList = Engine(Stream.LazyList)

let bank_ls =
  let c = open_in "bank_lsystem" in
  let r = lsystem_from_chanel c in
  close_in c; r

let _ =
  List.iter
    (fun lsys ->
       check_arity lsys ;
       check_vardef lsys Mini_calc.Env.usual
    ) bank_ls

let find s =
  List.find (fun lsys -> lsys.name = s) bank_ls

let lsystems = [
  5, find "Von_koch" ;
  7, find "Von_koch" ;
  9, find "Von_koch" ;
  15, find "dragon" ;
  9, find "fougere" ;
  13, find "Tetradragon" ;
]

let streams i lsys =
  let open Stream in [
    "Sequence" ,
    (fun lsys -> Sequence.force @@ BeSequence.eval_lsys i lsys) , lsys ;
    "Seq"      ,
    (fun lsys -> Seq.force @@ BeSeq.eval_lsys i lsys)      , lsys ;
    "Enum"     ,
    (fun lsys -> Enum.force @@ BeEnum.eval_lsys i lsys)     , lsys ;
    "LazyList" ,
    (fun lsys -> LazyList.force @@ BeLazyList.eval_lsys i lsys) , lsys ;
  ]

let _ =
  let f (i,lsys) =
    Printf.printf "\n\n --- Lsystem %s for %i iterations ---\n%!" lsys.name i ;
    let l = streams i lsys in
    let res = throughputN ~style:Nil ~repeat:3 10 l in
    tabulate res
  in
  List.iter f lsystems
