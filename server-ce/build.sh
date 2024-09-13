#!/usr/bin/env bash

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE}")"
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"

MONOREPO_ROOT="$(dirname "${SCRIPT_DIR}")"
MONOREPO_REVISION=$(git rev-parse HEAD)
BRANCH_NAME=${BRANCH_NAME:-$(git rev-parse --abbrev-ref HEAD)}
OVERLEAF_BASE_BRANCH=${OVERLEAF_BASE_BRANCH:-"sharelatex/sharelatex-base:${BRANCH_NAME}"}
OVERLEAF_BASE_LATEST=${OVERLEAF_BASE_LATEST:-"sharelatex/sharelatex-base"}
OVERLEAF_BASE_TAG=${OVERLEAF_BASE_TAG:-"sharelatex/sharelatex-base:${BRANCH_NAME}-${MONOREPO_REVISION}"}
OVERLEAF_BRANCH=${OVERLEAF_BRANCH:-"sharelatex/sharelatex:${BRANCH_NAME}"}
OVERLEAF_LATEST=${OVERLEAF_LATEST:-"sharelatex/sharelatex"}
OVERLEAF_TAG=${OVERLEAF_TAG:-"sharelatex/sharelatex:${BRANCH_NAME}-${MONOREPO_REVISION}"}

build_base() {
  cp .dockerignore "${MONOREPO_ROOT}"
  docker build \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --progress=plain \
    --file Dockerfile-base \
    --pull \
    --cache-from "${OVERLEAF_BASE_LATEST}" \
    --cache-from "${OVERLEAF_BASE_BRANCH}" \
    --tag "${OVERLEAF_BASE_TAG}" \
    --tag "${OVERLEAF_BASE_BRANCH}" \
    "${MONOREPO_ROOT}"
}

build_community() {
  cp .dockerignore "${MONOREPO_ROOT}"
  docker build \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --progress=plain \
    --build-arg OVERLEAF_BASE_TAG="${OVERLEAF_BASE_TAG}" \
    --build-arg MONOREPO_REVISION="${MONOREPO_REVISION}" \
    --cache-from "${OVERLEAF_LATEST}" \
    --cache-from "${OVERLEAF_BRANCH}" \
    --file Dockerfile \
    --tag "${OVERLEAF_TAG}" \
    --tag "${OVERLEAF_BRANCH}" \
    "${MONOREPO_ROOT}"
}

all() {
  pushd "${MONOREPO_ROOT}/server-ce"
  build_base
  build_community
  popd
}

all
