(lang dune 2.0)
(name pp)

(license MIT)
(maintainers "Jeremie Dimino <jeremie@dimino.org>")
(authors
  "Jane Street Group, LLC <opensource@janestreet.com>"
  "Jeremie Dimino <jeremie@dimino.org>")
(source (github diml/pp))
(documentation "https://diml.github.io/pp/")

(generate_opam_files true)

(package
 (name pp)
 (depends
   (ocaml (>= 4.04.0))
   (ppx_expect :with-test))
 (synopsis "Pretty-printing")
 (description "
This library provides minimal support for Canonical S-expressions
[1]. Canonical S-expressions are a binary encoding of S-expressions
that is super simple and well suited for communication between
programs.

This library only provides a few helpers for simple applications. If
you need more advanced support, such as parsing from more fancy input
sources, you should consider copying the code of this library given
how simple parsing S-expressions in canonical form is.

To avoid a dependency on a particular S-expression library, the only
module of this library is parameterised by the type of S-expressions.

[1] https://en.wikipedia.org/wiki/Canonical_S-expressions
"))
