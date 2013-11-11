NAME :=    $(shell oasis query name)
VERSION := $(shell oasis query version)

BUILDFLAGS='-ocamlopt "ocamlfind ocamlopt -inline 10"'

# OASIS_START
# DO NOT EDIT (digest: bc1e05bfc8b39b664f29dae8dbd3ebbb)

SETUP = ocaml setup.ml

build: setup.data
	$(SETUP) -build $(BUILDFLAGS)

doc: setup.data build
	$(SETUP) -doc $(DOCFLAGS)
	cp doc/vonkoch.svg doc.docdir/vonkoch.svg

test: setup.data build
	$(SETUP) -test $(TESTFLAGS)

all:
	$(SETUP) -all $(ALLFLAGS)

install: setup.data
	$(SETUP) -install $(INSTALLFLAGS)

uninstall: setup.data
	$(SETUP) -uninstall $(UNINSTALLFLAGS)

reinstall: setup.data
	$(SETUP) -reinstall $(REINSTALLFLAGS)

clean:
	$(SETUP) -clean $(CLEANFLAGS)

distclean:
	$(SETUP) -distclean $(DISTCLEANFLAGS)

setup.data:
	$(SETUP) -configure $(CONFIGUREFLAGS)

.PHONY: build doc test all install uninstall reinstall clean distclean configure

# OASIS_STOP

upload-docs:
	make doc && git checkout gh-pages && cp _build/doc.docdir/* . &&
	git add * && git commit && git push gh-pages

tarball:
	git archive --format=tar --prefix=lilis-$(VERSION)/ HEAD \
	  | gzip > lilis-$(VERSION).tar.gz
