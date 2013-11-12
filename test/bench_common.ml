open Benchmark
open Lilis
open Stream

module BeSequence = Engine(Stream.Sequence)
module BeSeq = Engine(Stream.Seq)
module BeEnum = Engine(Stream.Enum)
(* module BeStream = Engine(Stream.Stream) *)
module BeLazyList = Engine(Stream.LazyList)

let sequence i lsys =
  "Sequence", (fun lsys -> Sequence.force @@ BeSequence.eval_lsys i lsys), lsys

let seq i lsys =
  "Seq", (fun lsys -> Seq.force @@ BeSeq.eval_lsys i lsys), lsys

let enum i lsys =
  "Enum", (fun lsys -> Enum.force @@ BeEnum.eval_lsys i lsys), lsys

let lazy_list i lsys =
  "LazyList", (fun lsys -> LazyList.force @@ BeLazyList.eval_lsys i lsys), lsys

let all_streams = [
  sequence ;
  seq ;
  enum ;
  lazy_list ;
]

let get_bank_ls s =
  let c = open_in s in
  let r = lsystem_from_chanel c in
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
