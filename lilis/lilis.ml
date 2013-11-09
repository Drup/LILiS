include Ls_type

module Stream = Ls_stream

include Ls_utils

include Ls_syntax

module Lstream = Stream.Sequence

include Ls_engine

module E = Engine(Lstream)

let eval_lsys = E.eval_lsys
