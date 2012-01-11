#!/bin/sh

set -e

FLAGS="-use-ocamlfind"

OCAMLBUILD="ocamlbuild "

ocbn()
{
  $OCAMLBUILD $FLAGS $*
}

ocbb()
{
  $OCAMLBUILD $FLAGS $*
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
