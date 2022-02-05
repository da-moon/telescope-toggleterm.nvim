# syntax = docker/dockerfile:1.3-labs
# vim: filetype=dockerfile softtabstop=2 tabstop=2 shiftwidth=2 fenc=utf-8 fileformat=unix expandtab

#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────
#
#  ──── BASE LAYERS START ─────────────────────────────────────────────
#
#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────

#
#  ──── GOLANG BUILDER BASE LAYER ─────────────────────────────────────
#

FROM golang:alpine AS go-builder
USER root
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN apk add --no-cache "bash~=5.1"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
ARG BASE_PACKAGES="\
  build-base~=0.5 \
  ca-certificates~=20191127 \
  cmake~=3 \
  coreutils~=9 \
  curl~=7 \
  git~=2 \
  findutils~=4 \
  make~=4 \
  util-linux~=2 \
  wget~=1 \
  "
RUN  \
  IFS=' ' read -a BASE_PACKAGES <<< $BASE_PACKAGES ; \
  go env -w "GO111MODULE=on" \
  && go env -w "CGO_ENABLED=0" \
  && go env -w "CGO_LDFLAGS=-s -w -extldflags '-static'" \
  && apk add --no-cache "${BASE_PACKAGES[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --no-cache "${BASE_PACKAGES[@]}" \
  )
#
#  ──── RUST BUILDER BASE LAYER ───────────────────────────────────────
#
FROM alpine:edge AS rust-builder
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN apk add --no-cache "bash~=5.1"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
ARG BASE_PACKAGES="\
  build-base~=0.5 \
  ca-certificates~=20191127 \
  cmake~=3 \
  coreutils~=9 \
  curl~=7 \
  gcc~=10 \
  git~=2 \
  make~=4 \
  musl-dev~=1 \
  ncurses-static~=6 \
  openssl-dev~=1 \
  openssl-libs-static~=1 \
  "
RUN \
  IFS=' ' read -a packages <<< $BASE_PACKAGES ; \
  ( \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null  \
  && apk add --no-cache "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --no-cache "${packages[@]}" \
  )
# ────────────────────────────────────────────────────────────────────────────────
ARG RUST_VERSION="1.54.0"
ARG RUSTUP_URL="https://sh.rustup.rs"
ENV RUSTUP_HOME="/usr/local/rustup"
ENV CARGO_HOME="/usr/local/cargo"
ENV PATH="${CARGO_HOME}/bin:${PATH}"
ENV RUST_VERSION "${RUST_VERSION}"
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  case "$(apk --print-arch)" in \
  x86_64 | aarch64) \
  true \
  ;; \
  *) \
  exit 1 \
  ;; \
  esac; \
  curl --proto '=https' --tlsv1.2 -fSsl "${RUSTUP_URL}" | bash -s -- -y \
  --no-modify-path \
  --profile minimal \
  --default-toolchain "${RUST_VERSION}" \
  --default-host "$(apk --print-arch)-unknown-linux-musl" \
  && chmod -R a+w "${RUSTUP_HOME}" "${CARGO_HOME}" \
  && rustup --version \
  && cargo --version \
  && rustc --version \
  && rustup toolchain install "stable-$(apk --print-arch)-unknown-linux-musl" \
  && rustup toolchain install "nightly-$(apk --print-arch)-unknown-linux-musl" \
  && rustup default "stable-$(apk --print-arch)-unknown-linux-musl" \
  && cargo search hello-world
COPY <<-"EOT" /usr/local/cargo/config
[target.x86_64-unknown-linux-musl]
  rustflags = ["-C", "target-feature=+crt-static"]
[target.aarch64-unknown-linux-musl]
  rustflags = ["-C", "target-feature=+crt-static"]
[target.armv7-unknown-linux-musleabihf]
  linker = "arm-linux-gnueabihf-gcc"
EOT
ENV OPENSSL_STATIC=yes
ENV OPENSSL_LIB_DIR="/usr/lib"
ENV OPENSSL_INCLUDE_DIR="/usr/include"
WORKDIR "/workspace"
#
#  ──── COMPRESSION LAYER ─────────────────────────────────────────────
#
FROM alpine:edge as upx
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN apk add --no-cache "bash~=5.1"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
ARG BASE_PACKAGES="\
  coreutils~=9 \
  findutils~=4 \
  binutils~=2 \
  file~=5 \
  "
RUN \
  IFS=' ' read -a packages <<< $BASE_PACKAGES ; \
  ( \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null  \
  && apk add --no-cache "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --no-cache "${packages[@]}" \
  )
ARG UPX_DEPS="\
  curl~=7.79 \
  jq~=1.6 \
  xz~=5.2 \
  "
RUN \
  IFS=' ' read -a packages <<< $UPX_DEPS ; \
  apk add --no-cache --virtual .deps-upx "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --no-cache --virtual .deps-upx "${packages[@]}" \
  )
ARG REPO="upx/upx"
ARG LATEST_RELEASE_ENDPOINT="https://api.github.com/repos/${REPO}/releases/latest"
RUN \
  tag_name="$(curl -sL ${LATEST_RELEASE_ENDPOINT} | jq -r '.tag_name')"; \
  architecture="$(apk --print-arch)"; \
  case "$architecture" in \
    x86_64|amd64) \
      architecture="amd64" \
    ;; \
    aarch64) \
      architecture="arm64" \
    ;; \
    *) \
      echo >&2 "[ WARN ] compression utilities are not available: $architecture"; \
      exit 0 \
    ;; \
  esac ; \
  version="$(echo ${tag_name} | sed 's/v//g')"; \
  download_url="https://github.com/upx/upx/releases/download/${tag_name}/upx-${version}-${architecture}_linux.tar.xz"; \
  rm -rf \
    /tmp/{upx.tar,upx.tar.xz} \
    /usr/local/bin/upx \
  && echo "$download_url" > /tmp/dl \
  && curl -fsSLo /tmp/upx.tar.xz "${download_url}" \
  && xz -d -c /tmp/upx.tar.xz \
  | tar \
    -xOf - upx-${version}-${architecture}_linux/upx > /usr/local/bin/upx
#  ────────────────────────────────────────────────────────────────────
COPY <<-"EOT" /usr/local/bin/compress
#!/usr/bin/env bash
set -euo pipefail
apkArch="$(apk --print-arch)";
case "$apkArch" in
  x86_64|aarch64)
    find . \
    -type f \
    -executable \
    -exec sh -c "file -i '{}' |  grep -q 'charset=binary'" \; \
    -print \
    | xargs \
        -P `nproc` \
        --no-run-if-empty \
        bash -c '
      for pkg do
          strip "$pkg" || true ;
          upx "$pkg" || true ;
      done' bash ;
    ;;
  *)
    echo >&2 "[ WARN ] compression utilities are not available: $apkArch";
    exit 1
  ;;
esac;
find . \
  -mindepth 2 \
  -type f \
  -executable \
  -exec sh -c "file -i '{}' | grep -q 'charset=binary'" \; \
  -print \
  | xargs -P `nproc` -I {} --no-run-if-empty \
    mv "{}" ./
find . -mindepth 1 -maxdepth 1 -type d -exec rm -r "{}" \;
EOT
#  ────────────────────────────────────────────────────────────────────
# [ NOTE ] deleting dependencies on aarch64 leads to the following error
# PROT_EXEC|PROT_WRITE failed.
RUN \
  chmod a+x /usr/local/bin/* \
  && upx --version \
  [ "$(apk --print-arch)" == "aarch64" ] && apk del .deps-upx || true ; \
  rm -rf \
    /var/cache/apk/* \
    /var/tmp/* \
    /tmp/* ;
WORKDIR "/workspace"

#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────
#
#  ──── BASE LAYERS END ───────────────────────────────────────────────
#
#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────


#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────
#
#  ──── BUILDER LAYERS START ─────────────────────────────────────────
#
#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────

FROM go-builder AS yq-builder
ARG YQ_BRANCH="master"
RUN \
  set -xeu ; \
  git clone \
  --depth 1 \
  --branch "${YQ_BRANCH}" \
  "https://github.com/mikefarah/yq.git" \
  "/workspace"
WORKDIR "/workspace"
# hadolint ignore=SC2046
RUN \
  --mount=type=cache,target="/root/.cache/go-build" \
  --mount=type=cache,target="/go/pkg/mod" \
  --mount=type=tmpfs,target="/go/src/" \
  set -xeu ; \
  git fetch --all --tags && \
  git checkout \
  "$(git describe --tags $(git rev-list --tags --max-count=1))"  && \
  go build -o "/go/bin/yq" "./"

#
#  ──── RUST TOOLS ───────────────────────────────────────────────────
#

FROM rust-builder AS convco-builder
WORKDIR "/workspace"
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  export apkArch="$(apk --print-arch)" ; \
  case "${apkArch}" in \
  x86_64 | aarch64) \
  true \
  ;; \
  *) \
  exit 1 \
  ;; \
  esac; \
  [ "${apkArch}" == "aarch64" ] && export CFLAGS="-mno-outline-atomics" || true ; \
  rustup run --install stable cargo install \
    --all-features \
    --root "/workspace" \
    --target "${apkArch}-unknown-linux-musl" \
  "convco" ; \
  exe="/workspace/bin/convco" ; \
  if [[ ! -z $(readelf -d "${exe}" | grep NEED) ]]; then \
      if ldd ${exe} > /dev/null 2>&1; then \
        echo >&2 "*** '${exe}' was not linked statically"; \
        exit 1; \
      fi \
  fi \
  && mv "$exe" "/workspace/$(basename $exe)"
FROM rust-builder AS ttdl-builder
WORKDIR "/workspace"
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  export apkArch="$(apk --print-arch)" ; \
  case "${apkArch}" in \
  x86_64 | aarch64) \
  true \
  ;; \
  *) \
  exit 1 \
  ;; \
  esac; \
  [ "${apkArch}" == "aarch64" ] && export CFLAGS="-mno-outline-atomics" || true ; \
  rustup run --install stable cargo install \
    --all-features \
    --root "/workspace" \
    --target "${apkArch}-unknown-linux-musl" \
    "ttdl" ; \
  exe="/workspace/bin/ttdl" ; \
  if [[ ! -z $(readelf -d "${exe}" | grep NEED) ]]; then \
      if ldd ${exe} > /dev/null 2>&1; then \
        echo >&2 "*** '${exe}' was not linked statically"; \
        exit 1; \
      fi \
  fi \
  && mv "$exe" "/workspace/$(basename $exe)"
FROM rust-builder AS stylua-builder
WORKDIR "/workspace"
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  export apkArch="$(apk --print-arch)" ; \
  case "${apkArch}" in \
  x86_64 | aarch64) \
  true \
  ;; \
  *) \
  exit 1 \
  ;; \
  esac; \
  [ "${apkArch}" == "aarch64" ] && export CFLAGS="-mno-outline-atomics" || true ; \
  rustup run --install stable cargo install \
    --all-features \
    --root "/workspace" \
    --target "${apkArch}-unknown-linux-musl" \
    "stylua" ; \
  exe="/workspace/bin/stylua" ; \
  if [[ ! -z $(readelf -d "${exe}" | grep NEED) ]]; then \
      if ldd ${exe} > /dev/null 2>&1; then \
        echo >&2 "*** '${exe}' was not linked statically"; \
        exit 1; \
      fi \
  fi \
  && mv "$exe" "/workspace/$(basename $exe)"
FROM rust-builder AS selene-builder
WORKDIR "/workspace"
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  export apkArch="$(apk --print-arch)" ; \
  case "${apkArch}" in \
  x86_64 | aarch64) \
  true \
  ;; \
  *) \
  exit 1 \
  ;; \
  esac; \
  [ "${apkArch}" == "aarch64" ] && export CFLAGS="-mno-outline-atomics" || true ; \
  rustup run --install stable cargo install \
    --all-features \
    --root "/workspace" \
    --target "${apkArch}-unknown-linux-musl" \
    --branch "main" \
    --git "https://github.com/Kampfkarren/selene" \
    "selene" ; \
  exe="/workspace/bin/selene" ; \
  if [[ ! -z $(readelf -d "${exe}" | grep NEED) ]]; then \
      if ldd ${exe} > /dev/null 2>&1; then \
        echo >&2 "*** '${exe}' was not linked statically"; \
        exit 1; \
      fi \
  fi \
  && mv "$exe" "/workspace/$(basename $exe)"
FROM rust-builder AS sd-builder
WORKDIR "/workspace"
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  export apkArch="$(apk --print-arch)" ; \
  case "${apkArch}" in \
  x86_64 | aarch64) \
  true \
  ;; \
  *) \
  exit 1 \
  ;; \
  esac; \
  rustup run --install stable cargo install \
    --all-features \
    --root "/workspace" \
    --target "${apkArch}-unknown-linux-musl" \
    "sd" ; \
  exe="/workspace/bin/sd" ; \
  if [[ ! -z $(readelf -d "${exe}" | grep NEED) ]]; then \
      if ldd ${exe} > /dev/null 2>&1; then \
        echo >&2 "*** '${exe}' was not linked statically"; \
        exit 1; \
      fi \
  fi \
  && mv "$exe" "/workspace/$(basename $exe)"
FROM rust-builder AS sad-builder
WORKDIR "/workspace"
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  export apkArch="$(apk --print-arch)" ; \
  case "${apkArch}" in \
  x86_64 | aarch64) \
  true \
  ;; \
  *) \
  exit 1 \
  ;; \
  esac; \
  rustup run --install stable cargo install \
    --all-features \
    --root "/workspace" \
    --target "${apkArch}-unknown-linux-musl" \
    --git "https://github.com/ms-jpq/sad" ; \
  exe="/workspace/bin/sad" ; \
  if [[ ! -z $(readelf -d "${exe}" | grep NEED) ]]; then \
      if ldd ${exe} > /dev/null 2>&1; then \
        echo >&2 "*** '${exe}' was not linked statically"; \
        exit 1; \
      fi \
  fi \
  && mv "$exe" "/workspace/$(basename $exe)"
FROM rust-builder AS helix-builder
WORKDIR "/workspace"
RUN \
  git clone \
    --recurse-submodules \
    --shallow-submodules \
    -j"$(nproc)" \
    "https://github.com/helix-editor/helix" "/tmp/helix"
WORKDIR "/tmp/helix"
RUN \
  --mount=type=cache,target=/root/.cargo \
  --mount=type=cache,target=/usr/local/cargo/registry \
  rustup run --install stable cargo install \
    --all-features \
    --locked \
    --jobs "$(nproc)" \
    --root "/workspace"  \
    --target "$(apk --print-arch)-unknown-linux-musl" \
    --path "helix-term"
WORKDIR "/workspace"
RUN \
  exe="/workspace/bin/hx" ; \
  if [[ ! -z $(readelf -d "${exe}" | grep NEED) ]]; then \
      if ldd ${exe} > /dev/null 2>&1; then \
        echo >&2 "*** '${exe}' was not linked statically"; \
        exit 1; \
      fi \
  fi \
  && mv "$exe" "/workspace/$(basename $exe)"
#
#  ──── COMPRESS ─────────────────────────────────────────────────────
#
FROM upx AS compression-layer
COPY --chmod=0755 --from="yq-builder" "/go/bin/yq" "/workspace/bin/yq"
COPY --chmod=0755 --from="convco-builder" "/workspace" "/workspace"
COPY --chmod=0755 --from="sd-builder" "/workspace" "/workspace"
COPY --chmod=0755 --from="ttdl-builder" "/workspace" "/workspace"
COPY --chmod=0755 --from="sad-builder" "/workspace" "/workspace"
COPY --chmod=0755 --from="stylua-builder" "/workspace" "/workspace"
COPY --chmod=0755 --from="selene-builder" "/workspace" "/workspace"
COPY --chmod=0755 --from="helix-builder" "/workspace" "/workspace"
RUN \
  compress ;

#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────
#
#  ──── BUILDER LAYERS END ───────────────────────────────────────────
#
#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────
#  ────────────────────────────────────────────────────────────────────

#
#  ──── MAIN LAYER ───────────────────────────────────────────────────
#
FROM alpine:edge
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
ENV TERM xterm
RUN \
  ( \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" ; \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" ; \
  ) | tee /etc/apk/repositories > /dev/null  \
  && apk add --no-cache "bash~=5.1"
# ────────────────────────────────────────────────────────────────────────────────
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG BASE_PACKAGES="\
  bat~=0 \
  shfmt~=3 \
  exa~=0 \
  tokei~=12 \
  delta~=0 \
  just~=0 \
  acl~=2 \
  alpine-sdk~=1 \
  bash-completion~=2 \
  binutils~=2 \
  build-base~=0.5 \
  ca-certificates~=20191127 \
  cmake~=3 \
  coreutils~=9 \
  ctags~=5 \
  curl~=7 \
  doxygen~=1 \
  findutils~=4 \
  fontconfig~=2 \
  gawk~=5 \
  git~=2 \
  grep~=3 \
  jq~=1 \
  less=590-r0 \
  make~=4 \
  mkfontscale~=1 \
  ncurses~=6 \
  ncurses-dev~=6 \
  ncurses-static~=6 \
  openssl~=1 \
  openssl-dev~=1 \
  perl~=5 \
  shadow~=4 \
  starship~=1 \
  sudo~=1 \
  tmux~=3 \
  tree~=1 \
  tzdata~=2021e \
  util-linux~=2 \
  wget~=1 \
  unzip~=6 \
  xclip~=0.13 \
  xsel~=1 \
  zlib-dev~=1 \
  aria2~=1 \
  bzip2~=1 \
  docker~=20 \
  docker-compose~=1 \
  git-secret~=0.4 \
  glow~=1 \
  gnupg~=2 \
  gtest-dev~=1 \
  htop~=3 \
  libcap~=2 \
  libffi-dev~=3 \
  moreutils~=0 \
  musl-dev~=1 \
  nerd-fonts~=2 \
  rcm~=1 \
  yj~=1 \
  "
RUN \
  IFS=' ' read -a packages <<< $BASE_PACKAGES ; \
  apk add --no-cache "${packages[@]}" \
  || ( \
  sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories \
  && apk add --no-cache "${packages[@]}") \
  && cat '/usr/share/zoneinfo/Canada/Eastern' > /etc/localtime \
  && echo '[ -r /etc/profile ] && . /etc/profile' > "/root/.bashrc"
# ────────────────────────────────────────────────────────────────────────────────
USER root
ARG USER="vscode"
ENV USER "${USER}"
ARG UID="1000"
ENV UID $UID
ENV SHELL="/bin/bash"
ENV HOME="/home/${USER}"
RUN \
  useradd \
  --no-log-init \
  --create-home \
  --user-group \
  --home-dir "${HOME}" \
  --uid "${UID}" \
  --shell "${SHELL}" \
  --password "$(openssl passwd -1 -salt SaltSalt '${USER}' 2>/dev/null)" \
  "${USER}" \
  && sed -i \
    -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
    -e '/%sudo.*NOPASSWD:ALL/d' \
  "/etc/sudoers" \
  && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> "/etc/sudoers" \
  && usermod -aG wheel,root "${USER}" \
  && addgroup sudo > /dev/null 2>&1 || true ; adduser "${USER}" sudo \
  && addgroup docker > /dev/null 2>&1 || true ; adduser "${USER}" docker \
  && visudo --check > /dev/null 2>&1 \
  && find "${HOME}" \
    -not -group "$(id -g "${USER}")" \
    -not -user "$(id -u "${USER}")" \
    -print0 \
    | xargs -0 -r -I {} -P "$(nproc)" \
    chown --no-dereference "$(id -u "${USER}"):$(id -g "${USER}")" {}
# ────────────────────────────────────────────────────────────────────────────────
USER "root"
ARG LUA_VERSION="5.2"
ENV PATH="${PATH}:${HOME}/.luarocks/bin"
# ENV LUA_PATH=/usr/local/share/lua/5.3/?.lua;/usr/local/share/lua/5.3/?/init.lua;/usr/local/lib/lua/5.3/?.lua;/usr/local/lib/lua/5.3/?/init.lua;/usr/share/lua/5.3/?.lua;/usr/share/lua/5.3/?/init.lua;/usr/lib/lua/5.3/?.lua;/usr/lib/lua/5.3/?/init.lua;/usr/share/lua/common/?.lua;/usr/share/lua/common/?/init.lua;./?.lua;./?/init.lua
# ENV LUA_CPATH=/usr/local/lib/lua/5.3/?.so;/usr/local/lib/lua/5.3/loadall.so;/usr/lib/lua/5.3/?.so;/usr/lib/lua/5.3/loadall.so;./?.so
RUN \
  apk add --no-cache \
    "lua${LUA_VERSION}~=5" \
    "lua${LUA_VERSION}-dev~=5" \
    "luajit~=2" \
    "luarocks~=2" \
  && ln -s "/usr/bin/luarocks-${LUA_VERSION}" "/usr/bin/luarocks" \
  && luarocks --version \
  && find "${HOME}" \
  -not -group "$(id -g "${USER}")" \
  -not -user "$(id -u "${USER}")" \
  -print0 \
  | xargs -0 -r -I {} -P "$(nproc)" \
  chown --no-dereference "$(id -u "${USER}"):$(id -g "${USER}")" {} ;
# ─── NEOVIM REQUIREMENTS ────────────────────────────────────────────────────────
USER root
RUN \
  apk add \
    --no-cache \
    gzip~=1 \
    tree-sitter-cli~=0 \
    sqlite-dev~=3 \
    fd~=8 \
    ripgrep~=13 \
    ripgrep-bash-completion~=13 \
    fzf~=0 \
    fzf-bash-completion~=0 \
    xclip~=0 \
    xsel~=1 \
    npm~=14 \
    yarn~=1 \
    python3-dev~=3 \
    py3-pip~=21 \
    py3-virtualenv~=20 \
    py3-setuptools~=52 \
    py3-wheel~=0.36 \
    py3-pynvim~=0 \
  && npm install -g neovim \
  && yarn cache clean --all \
  && npm -g cache clean --force > /dev/null 2>&1
# ─── SETTING UP USER DOTFILES ───────────────────────────────────────────────────
USER "${USER}"
ENV EDITOR="hx"
ENV VISUAL="hx"
ENV COLORTERM="truecolor"
ENV PATH="${PATH}:/usr/local/bin"
ENV PATH="${PATH}:${HOME}/.local/bin"
ENV PATH="${PATH}:${HOME}/.git-fuzzy/bin/"
RUN \
  mkdir -p "${HOME}/.ssh" \
  && touch "${HOME}/.ssh/config" \
  && python3 -m pip install --user pre-commit \
  && git clone "https://github.com/wfxr/forgit" "${HOME}/.forgit" \
  && git clone https://github.com/bigH/git-fuzzy "${HOME}/.git-fuzzy" \
  && chmod a+x ${HOME}/.git-fuzzy/bin/* \
  && git clone "https://github.com/da-moon/.dotfiles.git" "${HOME}/.dotfiles" \
  && rcup -f  \
  && ( \
    echo '[ -r "/var/run/docker.sock" ] && sudo setfacl -m "$(id -u "${USER}")":rw "/var/run/docker.sock";' ; \
    echo '[ -r "${HOME}/.bashrc" ] && . "${HOME}/.bashrc" ;' ; \
  ) | tee -a  "${HOME}/.profile" > /dev/null \
  && mkdir -p "~/.config/helix/runtime" \
  && wget -qO - https://github.com/helix-editor/helix/archive/refs/heads/master.tar.gz \
  | tar -C "~/.config/helix/runtime" --strip-components=2 -xzf - "helix-master/runtime" \
  && echo "#!/usr/bin/env bash" > "${HOME}/.environment" ; \
  [ -d "${HOME}/.env.d" ] && while read -r i; do \
  sed -e '/^\s*#/d' "$i" | tee -a "${HOME}/.environment" > /dev/null \
  && printf "\n" >> "${HOME}/.environment" ; \
  done < <(find "${HOME}/.env.d/" -name '*.sh') ; \
  echo "#!/usr/bin/env bash" > "${HOME}/.bash_functions" ; \
  [ -d "${HOME}/.profile.d" ] && while read -r i; do \
  sed -e '/^\s*#/d' "$i" | tee -a "${HOME}/.bash_functions" > /dev/null \
  && printf "\n" >> "${HOME}/.bash_functions" ; \
  done < <(find "${HOME}/.profile.d/" -name '*.sh') ; \
  echo "#!/usr/bin/env bash" > "${HOME}/.bash_aliases" ; \
  [ -d "${HOME}/.alias.d" ] && while read -r i; do \
  sed -e '/^\s*#/d' "$i" | tee -a "${HOME}/.bash_aliases" > /dev/null \
  && printf "\n" >> "${HOME}/.bash_aliases" ; \
  done < <(find "${HOME}/.alias.d/" -name '*.sh') ;
# ────────────────────────────────────────────────────────────────────────────────
USER root
RUN \
  apk add \
    --no-cache \
    --virtual .neovim-build-deps \
     build-base \
     cmake \
     automake \
     autoconf \
     libtool \
     pkgconf \
     coreutils \
     curl \
     unzip \
     gettext-tiny-dev \
  && git clone "https://github.com/neovim/neovim.git" "/usr/local/src/neovim" \
  && export CMAKE_BUILD_TYPE="Release" \
  && export CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local" \
  && make -C "/usr/local/src/neovim" -j"$(nproc)"  \
  && unset CMAKE_BUILD_TYPE \
  && unset CMAKE_EXTRA_FLAGS \
  && make -C "/usr/local/src/neovim" -j"$(nproc)" install \
  && nvim --version \
  && apk del --no-cache --purge .neovim-build-deps
# ─── CLEAN UP ───────────────────────────────────────────────────────────────────
USER root
RUN \
  [ ! -r "/bin/cut" ] && ln -sf "$(command -v cut)" "/bin/cut" ; \
  chmod a+x /usr/local/bin/* \
  && chown -R "$(id -u "${USER}"):$(id -g "${USER}")" "${HOME}/.cache" \
  && rm -rf \
    /tmp/* \
    /usr/src

# ────────────────────────────────────────────────────────────────────────────────
USER "${USER}"
ARG WORKDIR="/workspace"
ENV WORKDIR "${WORKDIR}"
WORKDIR "${WORKDIR}"
# ────────────────────────────────────────────────────────────────────────────────
COPY --chmod=0755 --from=compression-layer "/workspace" "/usr/local/bin"
VOLUME "/var/run/docker.sock"
#  ────────────────────────────────────────────────────────────────────
ENTRYPOINT [ "/bin/bash" ]
