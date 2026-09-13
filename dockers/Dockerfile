FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    build-essential curl git ca-certificates \
    pkg-config libssl-dev bash \
    unzip zip \
    && rm -rf /var/lib/apt/lists/*

# Install Bazelisk as `bazel`. It reads /workspace/.bazelversion at runtime and
# fetches the matching Bazel release, so the version lives in the repo, not here.
ARG BAZELISK_VERSION=1.29.0
RUN arch="$(dpkg --print-architecture)" \
    && base="https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}" \
    && curl --proto '=https' --tlsv1.2 -fsSL "${base}/bazelisk-linux-${arch}" -o /usr/local/bin/bazel \
    && curl --proto '=https' --tlsv1.2 -fsSL "${base}/bazelisk-linux-${arch}.sha256" -o /tmp/bazelisk.sha256 \
    && echo "$(awk '{print $1}' /tmp/bazelisk.sha256)  /usr/local/bin/bazel" | sha256sum -c - \
    && rm /tmp/bazelisk.sha256 \
    && chmod 0755 /usr/local/bin/bazel

# Set up user
ARG USERNAME=samvaf
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Create user and add to sudo group
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && usermod -aG sudo $USERNAME \
    && mkdir -p /etc/sudoers.d \
    && echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USERNAME \
    && chsh -s /bin/bash $USERNAME

USER $USERNAME
WORKDIR /workspace

ENV RUSTUP_HOME=/home/${USERNAME}/.rustup \
    CARGO_HOME=/home/${USERNAME}/.cargo
ENV PATH="${CARGO_HOME}/bin:${PATH}"

# Install Rust toolchain as the non-root user
RUN curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf \
    | sh -s -- -y --no-modify-path
