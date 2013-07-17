# LILiS

LILiS is *Library to Interpret Lindenmayer Systems*.

![Von Koch](http://drup.github.io/LILiS/vonkoch.svg)

## L-system

[L-systems](http://en.wikipedia.org/wiki/L-system) are a kind of formal grammar defined by Lindermayer.

## Description of LILiS

The goal of this project is to implement a library to evaluate L-systems and to visualise them (in 2D only).
The emphasis is put on speed and low memory occupation with the use of lazy evaluation.

This project is partially inspired by [Lpy](http://openalea.gforge.inria.fr/dokuwiki/doku.php?id=packages:vplants:lpy:main).

The project is split is 4 parts:
- A small library to calculate arithmetic expressions;
- A library to parse and evaluate L-systems;
- A graphic library to draw such L-systems;
- An executable.

The documentation for the various libraries can be found [here](http://drup.github.io/LILiS/).

The executable can be used to draw any L-system like those in [`bank_lsystem`](bank_lsystem) for examples.

## Dependencies

- The parser depends on `menhir`.
- The engine implementation depends on [Batteries Included](https://github.com/ocaml-batteries-team/batteries-included).
- There is currently two graphical backends :
  - The png and gtk one depends on [Cairo's Ocaml binding](https://forge.ocamlcore.org/projects/cairo/).
  - The SVG on the *development* version of [tyxml](http://ocsigen.org/tyxml/).
- `Cmdliner` is used by the executable `glilis_ex`.

You can install most of it with :

	$ opam install batteries cairo lablgtk cmdliner menhir

See [here](http://ocsigen.org/install#source) for the development version of tyxml.

## How to

To build, just do :

	$ make

It will produce an executable `glilis_ex.native`. See `glilis_ex.native --help` for more information.

You can use two flags with `configure` : `--disable-cairo` and `--disable-tyxml` to disable the relevant libraries. Both are enabled by default.

To produce the documentation :

	$ make doc

You can also install `mini_calc` and `lilis` as libraries with :

	$ make install

### Building `lablgtk` and `cairo` on OS X

[Homebrew](http://mxcl.github.io/homebrew/) users may fail to build `lablgtk`.

This is due to broken location of some `pkg-config` files.
See <https://github.com/mxcl/homebrew/issues/14123>

To build `lablgtk`, do:

	brew install cairo
	export PKG_CONFIG_PATH="$(brew --prefix cairo)/lib/pkgconfig:/usr/local/opt/pixman/lib/pkgconfig:/usr/local/opt/fontconfig/lib/pkgconfig:/usr/local/opt/freetype/lib/pkgconfig:/usr/local/opt/libpng/lib/pkgconfig:/usr/X11/lib/pkgconfig"
	brew install gtk+
	opam install lablgtk cairo

## Architecture of the project

This project has three parts :
- `mini_calc`, a very small library to evaluate arithmetic expression;
- `lilis`, the core engine;
- `glilis`, the graphical stuff.

## TODO

Current potential goals:

- Implement a better error handling for the parser.
- Try other drawing library or maybe pur openGL.
- Make a pretty GUI.
- Improve the core engine.
- Extend the grammar, implement interpretation rules and do a bit of verification on the rules.


![Dragon](http://drup.github.io/LILiS/dragon.svg)
