# LILiS

LILiS is a *Library to Interpret Lindenmayer Systems*.

![Von Koch](http://drup.github.io/LILiS/dev/vonkoch.svg)

## L-system

[L-systems](http://en.wikipedia.org/wiki/L-system) are a kind of formal grammar defined by Lindermayer.

## Description of LILiS

The goal of this library is to evaluate L-systems and to visualise them (in 2D only).
The emphasis is put on high speed, static verifications and optimizations, modularity and pretty drawings.

This project is partially inspired by [Lpy](http://openalea.gforge.inria.fr/dokuwiki/doku.php?id=packages:vplants:lpy:main).

The project is split in 4 parts:
- A small library to calculate arithmetic expressions;
- A library to parse and evaluate L-systems;
- A graphic library to draw such L-systems;
- An executable.

The documentation for the various libraries can be found [here](http://drup.github.io/LILiS/dev/).

The executable can be used to draw any L-system like those in [`bank_lsystem`](bank_lsystem) for examples.

Computing L-systems happens to be a very nice way to stress the flatMap operation on some data structures. If you have any stream library (or other data structures) you want to test, feel free to ask.

## Dependencies

- The parser depends on `menhir`.
- [cppo](https://github.com/mjambon/cppo) is a building dependency.
- The engine implementation depends on [Batteries Included](https://github.com/ocaml-batteries-team/batteries-included) and [Sequence](https://github.com/c-cube/sequence) for super-fast streams.
- There is currently two graphical backends :
  - The png and gtk one depends on [Cairo's Ocaml binding](https://forge.ocamlcore.org/projects/cairo/).
  - The SVG one depends on [tyxml](http://ocsigen.org/tyxml/) (version >= 3.0.0).
- `Cmdliner` is used by the executable `glilis_ex`.

You can install most of it with :

	$ opam install cppo batteries sequence cairo lablgtk tyxml cmdliner menhir

## How to

To build, just do :

	$ make

The optional dependencies can be controlled by configure flags. See `configure --help` for a complete list.

To produce the documentation :

	$ make docs

You can also install the various libraries with :

	$ make install

If you used `configure` with the flag `--enable-executable` and both graphical backends, it will produce an executable `glilis_ex.native`. See `glilis_ex.native --help` for more information.

You can also enable benchmarks and tests with the flag `--enable-tests`. This will produce some benchmarking executable. Needs the [benchmark](http://ocaml-benchmark.sourceforge.net/) library.

## Architecture of the project

This project has three parts :
- `mini_calc`, a very small library to evaluate arithmetic expression;
- `lilis`, the core engine;
- `glilis`, the graphical stuff.
- `test`, some benchmarks

## TODO

Current potential goals:

- Big priority : add a preprocessor to do conditional compilation. This is the only way to handle all those optional dependencies nicely.

- Performance related :
  - Constants folding for symbols : replace `+(60)` by `+'` (with `def +' = Turn(60)`)
  - Constants folding for symbols, bis : replace `A B` with some other symbol if neither `A` nor `B` are left hand side of a rule.
  - Find a way to group arithmetic expressions. First in a given symbol `F(x*2,x*2)` and, more interesting : `rule F(x) = F(x/2) + F(x/2)`.
  - Symbol grouping : `F(x) F(y)` → `F(x+y)`. Be **very** careful as this is not always true.
  - Allow simple expressions to be pre-computed :
	  `rule S(n) = S(n+1)`. This may be super hard in general.
  - Allow to plug a (drawing) function in the last derivation, to avoid a useless flattening.
  - Work on the trigo stuff in the drawing part of the library.
  - Investigate the idea "Compute the size of the result in advance, allocate a huge array, copy the result of each rule, ???, profit." It may be a good way to parallelize lilis.
  - Play with Parmap a bit more, use the fact that the last operation is an iter (like for drawing) since we don't have to do the last (and very costly) concat in this case.

- Improve the verification some more, especially in relation to :
  - Token redefinition
  - Reusability (be able to recover the definition environment)

- New data structures! I'm always very happy to test them!
- Implement something by using a graph as a stream. The results may be quite interesting.

- Drawing :
  - New drawing engines!
  - In particular, Vg. <http://erratique.ch/software/vg>
  - Allow new drawing constructs. All the typing and modularity parts are in places, just need to implement.

- Make a pretty GUI, maybe a web one. See vg stuff.

- Add some benchmarks for drawing backends.

- Implement a better error handling for the parser.

- Work on the combinator approach for the front end.
- Currently, the definition environment disappear after the front end and only post rules remains. On one hand, we can't let the environment, as we can't trust it when it's given independently by the user, on an other hand, this prevent completing optional arguments from the library side. A solution (maybe with some abstract types), may be interesting. Beware of leaking abstractions.

![Dragon](http://drup.github.io/LILiS/dev/dragon.svg)
