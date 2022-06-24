### Ocaml Compiler build scripts

The repository is part of the [Compiler Explorer](https://godbolt.org/) project. It builds
the docker images used to build the various ocaml compilers used on the site.


# Testing locally

```
sudo docker build -t ocamlbuilder .
sudo docker run ocamlbuilder ./build.sh 4.10.1
```
