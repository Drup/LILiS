include Ls_type

module Stream = Ls_stream

include Ls_engine

include Ls_syntax

module Lstream = Stream.Seq

type lstream = (string * float array) Lstream.t

include Engine(Lstream)
