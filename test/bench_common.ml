open Benchmark
open Lilis
open Stream

module BeSequence = Make(LisSequence)
module BeGen = Make(LisGen)
module BeCFStream = Make(LisCFStream)
module BeSeq = Make(LisBatteries.Seq)
module BeEnum = Make(LisBatteries.Enum)
module BeStream = Make(LisBatteries.Stream)
module BeLazyList = Make(LisBatteries.LazyList)

let sequence i =
  "Sequence", (fun lsys -> LisSequence.force @@ BeSequence.eval_lsys i lsys)

let gen i =
  "Gen", (fun lsys -> LisGen.force @@ BeGen.eval_lsys i lsys)

let cfstream i =
  "CFStream", (fun lsys -> LisCFStream.force @@ BeCFStream.eval_lsys i lsys)

let seq i =
  "Seq", (fun lsys -> LisBatteries.Seq.force @@ BeSeq.eval_lsys i lsys)

let enum i =
  "Enum", (fun lsys -> LisBatteries.Enum.force @@ BeEnum.eval_lsys i lsys)

let lazy_list i =
  "LazyList", (fun lsys -> LisBatteries.LazyList.force @@ BeLazyList.eval_lsys i lsys)

let stream i =
  "Stream", (fun lsys -> LisBatteries.Stream.force @@ BeStream.eval_lsys i lsys)

let all_streams = [
  sequence ;
  gen ;
  cfstream ;
  seq ;
  enum ;
  lazy_list ;
  stream ;
]

let all_optims = [ "", LisOpti.constant_folding ]

let get_bank_ls s =
  let c = open_in s in
  let r = LisUtils.from_channel c in
  close_in c; r

let find bank s =
  List.find (fun lsys -> lsys.name = s) bank

type bench =
  | Throughput of int * int
  | Latency of int * Int64.t

let execute ?(bench=Throughput (3,10)) ?(tabulate=true) ?(style=Nil) bank lsystems optims streams =
  let bank = get_bank_ls bank in
  let lsystems = List.map (fun (i,s) -> (i,find bank s)) lsystems in
  let f (i,lsyss) =
    Printf.printf "\n\n --- Lsystem %s for %i iterations ---\n%!" (snd @@ List.hd lsyss).name i ;
    let l =
      List.concat @@ List.map
        (fun (name, lsys) ->
           List.map (fun f -> let (s,f) = f i in (s ^ name, f, lsys))
             streams)
        lsyss
    in
    let res = match bench with
      | Throughput (repeat, time) -> throughputN ~style ~repeat time l
      | Latency (repeat, n) -> latencyN ~style ~repeat n l
    in
    if tabulate then Benchmark.tabulate res
  in
  let optims =
    if optims = [] then ["", fun x -> x]
    else List.map (fun (n,f) -> ("+"^n,f)) optims
  in
  let lsystems =
    List.map (fun (i,lsys) -> (i, List.map (fun (v,f) -> (v, f lsys)) optims)) lsystems in
  List.iter f lsystems
