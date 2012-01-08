#!/bin/sh

set -e

#OCAMLBLDFLAGS := lablgtk.cma gtkInit.cmo
#OCAMLNLDFLAGS := lablgtk.cmxa gtkInit.cmx

#BFLAGS="-lflag gtkInit.cmo"
#NFLAGS="-lflag gtkInit.cmx"
FLAGS="-use-ocamlfind"
#LIBS="-libs batteries,calc,cairo"

OCAMLBUILD="ocamlbuild "

ocbn()
{
  $OCAMLBUILD $LIBS $FLAGS $NFLAGS $*
}

ocbb()
{
  $OCAMLBUILD $LIBS $FLAGS $BFLAGS $*
}

rule() {
  case $1 in
    clean)  ocbn -clean;;
    native) ocbn native.otarget;;
    byte)   ocbb byte.otarget;;
    depend) echo "Not needed.";;
    *)      echo "Unknown action $1";;
  esac;
}

if [ $# -eq 0 ]; then
  rule native
else
  while [ $# -gt 0 ]; do
    rule $1;
    shift
  done
fi
