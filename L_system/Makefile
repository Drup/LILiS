
OCAMLMAKEFILE := ../OCamlMakefile
MINICALC := ../mini-calc/

PACKS = batteries

SOURCES := type.ml crayon.ml graphic_order.ml Lsys_engine.ml ls_parser.mly ls_lexer.mll syntaxe.ml l_system.ml
RESULT := l_system

ANNOTATE := yes

INCDIRS := /usr/lib/ocaml/cairo/ $(MINICALC) +lablgtk2

LIBS := calc cairo cairo_lablgtk

OCAMLBLDFLAGS := lablgtk.cma gtkInit.cmo
OCAMLNLDFLAGS := lablgtk.cmxa gtkInit.cmx

all : nc

depends :
	$(MAKE) -C $(MINICALC)

-include $(OCAMLMAKEFILE)
