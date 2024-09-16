Unreleased
----------

- Update `make release` for `dune-release.2.0.0` (#22, @mbarbin).

2.0.0
-----

- Prepare release (#21, @mbarbin)
  - Upgrade to `ocamlformat.0.26.2`.
  - Fmt the code
  - Add CI badge to README
  - Upgrade GitHub workflow actions dependencies (checkout@v4, setup-ocaml@v3)
  - Add more validation steps in CI
  - Add `ocamlformat` as dev-setup dependency

- Add `Pp.verbatimf`. (#18, @mbarbin)

- Add `Pp.paragraph` and `Pp.paragraphf` (#19, @Alizter)

- Remove `of_fmt` constructor. (#17, @Alizter)

1.2.0
-----

- Add `Pp.compare` (#9, @Alizter)

1.1.2
-----

- Add `of_fmt` to compose with existing pretty printers written in `Format`
  (#1, @Drup).

- Use a tail-recursive `List.map` to fix a stack overflow issue (#3,
  @emillon)

- Add `Pp.custom_break` (#4, @gpetiot)

- Add `Ast` sub-module to expose a stable representation for
  serialization, allowing to do the rendering in another process (#6,
  @rgrinberg)

1.1.1
-----

Replaced by 1.1.2 because of wrong URLs in opam file.

1.1.0
-----

Replaced by 1.1.1 because of missing changelog entries.

1.0.1
-----

- Fix compat with OCaml 4.04

1.0.0
-----

- Initial release
