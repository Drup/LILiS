open Benchmark
open Lilis
open Bench_common

let lsystems = [
  13, "dragon" ;
]

let _ =
  execute
    ~bench:(Throughput (1,20))
    ~tabulate:true
    ~style:Benchmark.All
    "bank_lsystem" lsystems all_optims [sequence]
