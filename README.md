# LILiS

LILiS is *Library to Interpret Lindenmayer Systems*.

![Von Koch](http://drup.github.io/LILiS/vonkoch.svg)

## L-system

[L-systems](http://en.wikipedia.org/wiki/L-system) are a kind of formal grammar defined by Lindermayer.

## Description of LILiS

The goal of this project is to implement a library to evaluate L-systems and to visualise them (in 2D only).
The emphasis is put on speed and low memory occupation with the use of lazy evaluation.

This project is partially inspired by [Lpy](http://openalea.gforge.inria.fr/dokuwiki/doku.php?id=packages:vplants:lpy:main).

## Dependencies

- The engine implementation depends on [Batteries Included](https://github.com/ocaml-batteries-team/batteries-included).
- The graphical interface depends of the [cairo's ocaml binding](https://forge.ocamlcore.org/projects/cairo/).
  This may change in the future.
- `Cmdliner` is used by the executable `glilis`.

To install everything you need :

	$ opam install batteries cairo lablgtk cmdliner tyxml

## How to

### Build instructions

To build, just do :

	$ make

It will produce an executable `glilis.native`. Just do `./glilis.native --help` for more informations.

To see some examples of L-systems, look at [`bank_lsystem`](bank_lsystem).

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

- Rewrite the L-system parser.  
  Oh god, did I really write something this hideous ?
- Separate the drawing from the executable.
- Try other drawing library or maybe pur openGL.
- Implement an SVG export with `tyxml`.
- Make a pretty GUI.
- Improve the core engine.
- Extend the grammar, implement interpretation rules and do a bit of verification on the rules.


![Dragon](http://drup.github.io/LILiS/dragon.svg)
