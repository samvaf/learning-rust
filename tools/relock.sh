#!/usr/bin/env bash
set -euo pipefail

CARGO_BAZEL_REPIN=1 bazel fetch @crates//...
bazel run //:requirements.update