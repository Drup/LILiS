# LILiS

LILiS is *Library to Interpret Lindenmayer System*.

## L-system

[L-system][] are a kind of formal grammar defined by Lindermayer.

[L-system]: http://en.wikipedia.org/wiki/L-system


## Architecture of the project

This project has two parts :
	- mini_calc, a very small library to use arithmetic expression
	- lilis, the core engine
	- glilis, the graphical stuff

The actual implementation depends on batteries.
The graphical interface depends of the [ocaml binding of cairo][ocaml-cairo]. This may change in the future.

[ocaml-cairo]: https://forge.ocamlcore.org/projects/cairo/

## Description of LILiS

The goal of this project is to implement a library to evaluate L-system and to visualise them (in 2D only).
The emphasis is put on speed and low memory occupation with the use of lazy evaluation (in fact, constant memory occupation).

This project is partly inspired by [Lpy][].

[Lpy]: http://openalea.gforge.inria.fr/dokuwiki/doku.php?id=packages:vplants:lpy:main

To build, just do :

	$ make

it will produce an executable glilis.native.
It will ask you the l-system (Von Koch curve is the only avaible curently, feel free to extend the l-system bank !) and the generation then will show you the result in a GTK window.

To produce the documentation (very partial for now) :

	$ make doc

You can also install mini_calc an lilis as libraries with :

	$ make install

Current way of investigations :

- Separate the drawing from the evaluating library
- Try other drawing library or maybe pur openGL
- Implement a svg export with tyxml.
- Make a pretty GUI
- improve the core engine a bit more
- extend the grammar, implement interpretation rules and do a bit of formal verification
