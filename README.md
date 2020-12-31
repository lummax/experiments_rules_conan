Experiments with `conan` and `bazel`
====================================

This repository is a little experiment on how to integrate packages loaded
via `conan` into `bazel`. It is meant to be self-contained and only requires
a `python3` binary. This is currently only tested on Linux.

To run, type

```
bazel run //src:main
```

This will:
- setup a `venv` in which to install `conan`
- run `conan` to install the `fmt` C++ library
- compile a small hello-world program that uses the `fmt` loaded via `conan`

Please refer to the `WORKSPACE.bazel` file and the files in `support/bazel`
for more information.

TODOs
-----
- [x] POC
- [ ] Tests / Documentation
- [ ] Package this up?
- [ ] Additional arguments to the `venv` creation
- [ ] Additional arguments to the `pip install` invocation
- [ ] Additional arguments to the `conan install` invocation