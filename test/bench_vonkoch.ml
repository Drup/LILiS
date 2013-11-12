open Benchmark
open Lilis
open Bench_common

let lsystems = [
  4, "Von_koch" ;
  5, "Von_koch" ;
  6, "Von_koch" ;
  7, "Von_koch" ;
  8, "Von_koch" ;
  9, "Von_koch" ;
]

let _ =
  execute "bank_lsystem" lsystems [sequence]
