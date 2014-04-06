open Benchmark
open Lilis
open Bench_common

let lsystems = [
  7, "Von_koch" ;
  15, "dragon" ;
  9, "fern" ;
  12, "Tetradragon" ;
]

let _ =
  execute "bank_lsystem" lsystems all_streams
