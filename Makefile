INSTALL_ARGS := $(if $(PREFIX),--prefix $(PREFIX),)

default:
	dune build

test:
	dune runtest

install:
	dune install $(INSTALL_ARGS)

uninstall:
	dune uninstall $(INSTALL_ARGS)

reinstall: uninstall install

clean:
	dune clean

all-supported-ocaml-versions:
	dune runtest --workspace dune-workspace.dev

release:
	dune-release tag
	dune-release distrib --skip-build --skip-lint --skip-tests -n pp
# See https://github.com/ocamllabs/dune-release/issues/206
	DUNE_RELEASE_DELEGATE=github-dune-release-delegate dune-release publish distrib --verbose -n pp
	dune-release opam pkg -n pp
	dune-release opam submit -n pp

.PHONY: default install uninstall reinstall clean test
