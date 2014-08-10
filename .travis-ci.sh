PACKAGE=lilis

OPAM_VERSION=1.1.0
case "$OCAML_VERSION,$OPAM_VERSION" in
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

opam install ocamlfind containers menhir cppo oasis

if [ "${TEST}" != "" ] ; then
    TEST="-t"
    EXTRA_DEPENDS="${EXTRA_DEPENDS} benchmark" ;
fi

[ "${EXTRA_DEPENDS}" != "" ] && opam install ${EXTRA_DEPENDS}

opam install ${TEST} --verbose ${PACKAGE}
opam remove --verbose ${PACKAGE}


# If appropriate, build and push the documentation
if [ "$TRAVIS_REPO_SLUG" == "Drup/LILiS" ] \
    && [ "$TRAVIS_PULL_REQUEST" == "false" ] \
    && [ "$TRAVIS_BRANCH" == "master" ] \
    && [ "${DOC}" != "" ] ; then

    echo -e "Publishing ocamldoc...\n"
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "travis-ci"
    git clone https://${GH_TOKEN}@github.com/Drup/LILiS .documentation
    cd .documentation
    git fetch
    ./configure \
        --enable-cairo       \
        --enable-cfstream    \
        --enable-containers  \
        --enable-core-kernel \
        --enable-docs        \
        --enable-executable  \
        --enable-js-of-ocaml \
        --enable-profile     \
        --enable-tyxml
    make upload-docs

    if [ -n "$(git status --untracked-files=no --porcelain)" ]; then
        git commit -m "Update documentation $TRAVIS_BUILD_NUMBER"
        git push -q origin gh-pages
        echo -e "Published ocamldoc to gh-pages.\n"
    fi

fi
