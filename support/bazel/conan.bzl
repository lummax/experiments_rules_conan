def _generate_variables(repository_ctx, build_info):
    repository_ctx.template(
        "generate_variables.py",
        repository_ctx.path(Label("//support/bazel:generate_variables.py")),
        {},
    )

    python_interpreter = repository_ctx.attr.python_interpreter
    if repository_ctx.attr.python_interpreter_target != None:
        python_interpreter = repository_ctx.path(repository_ctx.attr.python_interpreter_target)
    else:
        if "/" not in python_interpreter:
            python_interpreter = repository_ctx.which(python_interpreter)
        if not python_interpreter:
            fail("python interpreter not found")

    result = repository_ctx.execute([
        python_interpreter,
        "generate_variables.py",
        build_info,
        "--output=variables.bzl",
    ], quiet = repository_ctx.attr.quiet)

    if result.return_code:
        fail("generate_variables.py failed: \nSTDOUT:\n%s\nSTDERR:\n%s" % (result.stdout, result.stderr))

def _conan_repository_impl(repository_ctx):
    repository_ctx.file(
        "BUILD.bazel",
        "",
        executable = False,
    )
    _generate_variables(
        repository_ctx,
        repository_ctx.path(repository_ctx.build_info_json),
    )

conan_repository = repository_rule(
    implementation = _conan_repository_impl,
    attrs = {
        "build_info_json": attr.label(
            mandatory = True,
        ),
        "python_interpreter": attr.string(default = "python3"),
        "python_interpreter_target": attr.label(allow_single_file = True),
        "quiet": attr.bool(default = True),
    },
)

def _conan_install_impl(repository_ctx):
    repository_ctx.file(
        "BUILD.bazel",
        "",
        executable = False,
    )

    conan_binary = repository_ctx.attr.conan_binary
    if repository_ctx.attr.conan_binary_target != None:
        conan_binary = repository_ctx.path(repository_ctx.attr.conan_binary_target)
    else:
        if "/" not in conan_binary:
            conan_binary = repository_ctx.which(conan_binary)
        if not conan_binary:
            fail("conan binary not found")

    result = repository_ctx.execute([
        conan_binary,
        "install",
        "--lockfile",
        repository_ctx.path(repository_ctx.attr.lockfile),
        repository_ctx.path(repository_ctx.attr.conanfile),
    ], quiet = repository_ctx.attr.quiet)

    if result.return_code:
        fail("conan install failed: \nSTDOUT:\n%s\nSTDERR:\n%s" % (result.stdout, result.stderr))

    _generate_variables(repository_ctx, "conanbuildinfo.json")

conan_install = repository_rule(
    implementation = _conan_install_impl,
    attrs = {
        "conanfile": attr.label(
            mandatory = True,
        ),
        "lockfile": attr.label(
            mandatory = True,
        ),
        "conan_binary": attr.string(default = "conan"),
        "conan_binary_target": attr.label(allow_single_file = True),
        "python_interpreter": attr.string(default = "python3"),
        "python_interpreter_target": attr.label(allow_single_file = True),
        "quiet": attr.bool(default = True),
    },
)
