# LILiS

LILiS is *Library to Interpret Lindenmayer Systems*.

## L-system

[L-systems][] are a kind of formal grammar defined by Lindermayer.

[L-systems]: http://en.wikipedia.org/wiki/L-system

## Description of LILiS

The goal of this project is to implement a library to evaluate L-systems and to visualise them (in 2D only).
The emphasis is put on speed and low memory occupation with the use of lazy evaluation.

This project is partially inspired by [Lpy][].

[Lpy]: http://openalea.gforge.inria.fr/dokuwiki/doku.php?id=packages:vplants:lpy:main

The engine implementation depends on batteries.
The graphical interface depends of the [ocaml binding of cairo][ocaml-cairo]. This may change in the future.
Cmdliner is used by the executable `glilis`.

To install everything you need :

	$ opam install batteries cairo lablgtk cmdliner tyxml

[ocaml-cairo]: https://forge.ocamlcore.org/projects/cairo/

## How to

To build, just do :

	$ make

It will produce an executable `glilis.native`. Just do `./glilis.native --help` for more informations.

To see some examples of L-systems, look at [bank_lsystem](bank_lsystem).

To produce the documentation :

	$ make doc

You can also install mini_calc and lilis as libraries with :

	$ make install
	
## Architecture of the project

This project has three parts :
- mini_calc, a very small library to evaluate arithmetic expression;
- lilis, the core engine;
- glilis, the graphical stuff.

## TODO

Current ways of investigations :

- Rewrite the L-system parser. Oh god, did I really write something this hideous ?
- Separate the drawing from the executable.
- Try other drawing library or maybe pur openGL.
- Implement an svg export with tyxml.
- Make a pretty GUI.
- Improve the core engine a bit more.
- Extend the grammar, implement interpretation rules and do a bit of verification on the rules.
