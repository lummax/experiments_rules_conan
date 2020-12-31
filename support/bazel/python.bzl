def _setup_venv_impl(repository_ctx):
    repository_ctx.file(
        "BUILD.bazel",
        "exports_files(%r)" % repository_ctx.attr.exports,
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
        "-m",
        "venv",
        "venv",
    ], quiet = repository_ctx.attr.quiet)

    if result.return_code:
        fail("venv creation failed: \nSTDOUT:\n%s\nSTDERR:\n%s" % (result.stdout, result.stderr))

    result = repository_ctx.execute([
        "./venv/bin/pip",
        "install",
        "--requirement",
        repository_ctx.path(repository_ctx.attr.requirements),
    ], quiet = repository_ctx.attr.quiet)

    if result.return_code:
        fail("pip install failed: \nSTDOUT:\n%s\nSTDERR:\n%s" % (result.stdout, result.stderr))

    for export in repository_ctx.attr.exports:
        repository_ctx.symlink("venv/bin/%s" % export, export)

setup_venv = repository_rule(
    implementation = _setup_venv_impl,
    attrs = {
        "requirements": attr.label(default = "//support/bazel:requirements.txt"),
        "python_interpreter": attr.string(default = "python3"),
        "python_interpreter_target": attr.label(allow_single_file = True),
        "exports": attr.string_list(allow_empty = False, default = ["pip", "conan"]),
        "quiet": attr.bool(default = True),
    },
)
