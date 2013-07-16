include Ls_type

module Stream = Ls_stream

include Ls_engine

include Ls_syntax

type lstream = (string * float array) Stream.Seq.t

module Lstream = Stream.Seq

include Engine(Lstream)
