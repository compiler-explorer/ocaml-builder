### Ocaml Compiler build scripts

The repository is part of the [Compiler Explorer](https://godbolt.org/) project. It builds
the docker images used to build the various ocaml compilers used on the site.

# HowTo

Use `admin-daily-build.sh` as a template, and use for example the following calls:
* `build_latest ocaml ocaml-4.10.1 build.sh 4.10.1`
* `build_latest ocaml ocaml-4.10.1-flambda build.sh 4.10.1-flambda`
