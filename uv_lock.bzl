"""A `bazel run` target that regenerates the Python lockfiles with uv.

uv needs to see the whole workspace and write back into the source tree, so this
is a run target operating on $BUILD_WORKSPACE_DIRECTORY rather than a build
action. That means adding a package needs no change here.
"""

_UV_TOOLCHAIN = "@rules_python//python/uv:uv_toolchain_type"

def _uv_lock_impl(ctx):
    uv = ctx.toolchains[_UV_TOOLCHAIN].uv_toolchain_info.uv[DefaultInfo].files_to_run.executable

    script = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(
        output = script,
        is_executable = True,
        content = """#!/usr/bin/env bash
set -euo pipefail
UV="$(pwd)/{uv}"
cd "$BUILD_WORKSPACE_DIRECTORY"
"$UV" lock
"$UV" export --all-packages --all-extras --no-emit-workspace \\
    --format requirements-txt -o {out}
echo "OK: regenerated uv.lock and {out}"
""".format(uv = uv.short_path, out = ctx.attr.out),
    )
    return DefaultInfo(executable = script, runfiles = ctx.runfiles(files = [uv]))

uv_lock = rule(
    implementation = _uv_lock_impl,
    executable = True,
    attrs = {"out": attr.string(default = "requirements_lock.txt")},
    toolchains = [_UV_TOOLCHAIN],
)
