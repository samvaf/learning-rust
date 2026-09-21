#!/usr/bin/env bash
set -euo pipefail

if command -v cargo >/dev/null; then
    cargo metadata --format-version 1 >/dev/null
fi

CARGO_BAZEL_REPIN=1 bazel fetch @crates//...
bazel run //:requirements.update