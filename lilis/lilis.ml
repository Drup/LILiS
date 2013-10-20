include Ls_type

module Stream = Ls_stream

include Ls_utils

include Ls_syntax

module Lstream = Stream.Sequence

type lstream = (string * float array) Lstream.t

include Ls_engine

include Engine(Lstream)
