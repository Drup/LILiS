open Benchmark
open Lilis
open Bench_common

let lsystems = [
  7, "Von_koch_simple" ;
  7, "Von_koch_bench" ;
  15, "dragon" ;
  9, "fern" ;
  12, "Tetradragon" ;
  100, "Spin_it" ;
]

let optims = [
  "", (fun x -> x) ;
  "const fold", LisOptim.constant_folding ;
]

let _ =
  execute ~style:All "bank_lsystem" lsystems optims [sequence]
