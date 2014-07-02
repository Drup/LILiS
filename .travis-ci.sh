# Edit this for your own project dependencies
PACKAGE=lilis

OPAM_VERSION=1.1.0
case "$OCAML_VERSION,$OPAM_VERSION" in
3.12.1,1.1.0) ppa=avsm/ocaml312+opam11 ;;
4.00.1,1.1.0) ppa=avsm/ocaml40+opam11 ;;
4.01.0,1.1.0) ppa=avsm/ocaml41+opam11 ;;
*) echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
esac

echo "yes" | sudo add-apt-repository ppa:$ppa
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam
export OPAMYES=1
echo OCaml version
ocaml -version
echo OPAM versions
opam --version
opam --git-version

opam init
eval `opam config env`

opam pin --verbose ${PACKAGE} .

#opam install --deps-only ${PACKAGE}
#Doesn't work with opam 1.1 for some reasons

opam install ocamlfind batteries menhir sequence cppo oasis

[ ${EXTRA_DEPENDS} ] && opam install ${EXTRA_DEPENDS}
opam install --verbose ${PACKAGE}
opam remove --verbose ${PACKAGE}
