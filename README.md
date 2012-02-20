# LILiS

LILiS is *Library to Interpret Lindenmayer System*.

## L-system

[L-system][] are a kind of formal grammar defined by Lindermayer.

[L-system]: http://en.wikipedia.org/wiki/L-system


## Architecture of the project

This project has two parts :
	- mini-calc, a very small library to use arithmetic expression
	- L-sytem, the core engine

The actual implementation depends of Batteries included and ocamlbuild.
The graphical interface depends of the [ocaml binding of cairo][ocaml-cairo]. This may change in the futur.

[ocaml-cairo]: https://forge.ocamlcore.org/projects/cairo/

## Description of LILiS

The goal of this project is to implement a library to evaluate L-system and to visualise them (in 2D only).
The emphasis is put on speed and low memory occupation with the use of lazy evaluation (in fact, constant memory occupation).

This project is partly inspired by [Lpy][].

[Lpy]: http://openalea.gforge.inria.fr/dokuwiki/doku.php?id=packages:vplants:lpy:main

To build, just do :

	$ sh make.sh

it will produce an executable l_system.native.
It will ask you the l-system (Von Koch curve is the only avaible curently, feel free to extend the l-system bank !) and the generation then will show you the result in a GTK window.


Curent way of investigation :

- Separate the drawing from the evaluating library
- Try other drawing library or maybe pur openGL
- Make a pretty GUI
- improve the core engine a bit more
- extend the grammar, implement interpretation rules and do a bit of formal verification
