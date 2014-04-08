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

let sequence i lsys =
  "Sequence", (fun lsys -> LisSequence.force @@ BeSequence.eval_lsys i lsys), lsys

let gen i lsys =
  "Gen", (fun lsys -> LisGen.force @@ BeGen.eval_lsys i lsys), lsys

let cfstream i lsys =
  "CFStream", (fun lsys -> LisCFStream.force @@ BeCFStream.eval_lsys i lsys), lsys

let seq i lsys =
  "Seq", (fun lsys -> LisBatteries.Seq.force @@ BeSeq.eval_lsys i lsys), lsys

let enum i lsys =
  "Enum", (fun lsys -> LisBatteries.Enum.force @@ BeEnum.eval_lsys i lsys), lsys

let lazy_list i lsys =
  "LazyList", (fun lsys -> LisBatteries.LazyList.force @@ BeLazyList.eval_lsys i lsys), lsys

let stream i lsys =
  "Stream", (fun lsys -> LisBatteries.Stream.force @@ BeStream.eval_lsys i lsys), lsys

let all_streams = [
  sequence ;
  gen ;
  cfstream ;
  seq ;
  enum ;
  lazy_list ;
  stream ;
]

let get_bank_ls s =
  let c = open_in s in
  let r = LisUtils.from_channel c in
  close_in c; r

let find bank s =
  List.find (fun lsys -> lsys.name = s) bank

type bench =
  | Throughput of int * int
  | Latency of int * Int64.t

let execute ?(bench=Throughput (3,10)) ?(tabulate=true) ?(style=Nil) bank lsystems streams =
  let bank = get_bank_ls bank in
  let lsystems = List.map (fun (i,s) -> (i,find bank s)) lsystems in
  let f (i,lsys) =
    Printf.printf "\n\n --- Lsystem %s for %i iterations ---\n%!" lsys.name i ;
    let l = List.map (fun f -> f i lsys) streams in
    let res = match bench with
      | Throughput (repeat, time) -> throughputN ~style ~repeat time l
      | Latency (repeat, n) -> latencyN ~style ~repeat n l
    in
    if tabulate then Benchmark.tabulate res
  in
  List.iter f lsystems
