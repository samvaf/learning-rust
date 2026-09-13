# just-learning-rust

Learning w/ [Rust Book Brown](https://rust-book.cs.brown.edu/)

A Bazel monorepo holding Rust and Python packages.

## Layout

`projects/` holds every package, Rust and Python alike. Each one declares its own
dependencies in its own manifest — `Cargo.toml` for a crate, `pyproject.toml` for
a Python package — and is listed once in the matching workspace at the root:
`Cargo.toml` for Rust, `pyproject.toml` for Python.

## How it fits together

Cargo and uv are **resolvers**: they decide which versions to use. Bazel is the
**builder**: it compiles, tests and caches. They meet only at the lockfiles.

```
  YOUR MANIFESTS                RESOLVER            ROOT LOCKFILE        BAZEL

projects/*/Cargo.toml    ──cargo──►  Cargo.lock  ──┐
                                                   ├─► crate_universe ─► @crates
                                     Cargo.Bazel.lock ┘                     │
                                                                            │
projects/*/                                                                 ▼
  pyproject.toml         ──uv────►  requirements_lock.txt ─► pip.parse ─► @pypi
                                                                            │
                                                                            ▼
                                                        projects/*/BUILD.bazel
                                                        rust_binary / py_library
```

uv also writes its own `uv.lock`; `requirements_lock.txt` is the flattened
export of it that `pip.parse` can read.

## Build and test

```bash
bazel build //...
bazel test //...
```

Cargo still works for the Rust crates and remains the source of truth for crate
dependencies — `crate_universe` generates the Bazel targets from it:

```bash
cargo run -p guessing_game
bazel run //projects/guessing_game
```

## Dependencies

Both languages resolve to a single repo-wide lockfile at the root, which
`MODULE.bazel` points at: `Cargo.lock` for Rust, `requirements_lock.txt` for
Python.

**Rust** — edit the crate's `Cargo.toml`, then re-pin:

```bash
CARGO_BAZEL_REPIN=1 bazel build //...
```

**Python** — edit the package's `pyproject.toml`, then re-lock:

```bash
bazel run //:requirements.update
```

Both re-resolve dependencies, write lockfiles back into the source tree and need
the network, so neither runs as part of `bazel build //...`. The Python target
uses the uv pinned in `MODULE.bazel`, so the result does not depend on what is
installed locally. Commit `uv.lock` and `requirements_lock.txt` together.

## Adding a package

1. Create `projects/<name>/` with its own `Cargo.toml` or `pyproject.toml`.
2. Add it to the `members` list in the root `Cargo.toml` or `pyproject.toml`.
3. Write `projects/<name>/BUILD.bazel`.
4. Re-resolve with the matching command above.

## CI

- `ci.yml` — `bazel build` and `bazel test` on every push to `main` and every PR.
- `publish-image.yml` — builds `dockers/Dockerfile` for linux/amd64 and
  linux/arm64 and pushes to `ghcr.io/samvaf/learning-rust-dev`.
