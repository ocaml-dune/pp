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

release:
	dune-release tag
	dune-release distrib --skip-build --skip-lint --skip-tests
	dune-release publish distrib --verbose
	dune-release publish doc --verbose
	dune-release opam pkg
	dune-release opam submit

.PHONY: default install uninstall reinstall clean test
