IMAGE := "docker.io/library/debian:bookworm"
PLATFORM := "linux/arm/v7"

setup:
    docker run --privileged --rm tonistiigi/binfmt --install all
    mkdir -p dist

#
# Patch existing debian dpkg files and use docker instead of cross compiling
#
patch-debian:
    #!/usr/bin/env bash
    set -e
    cd debian
    mkdir -p dist/
    docker buildx build --load --platform "{{PLATFORM}}" -t "debian-patch" --build-arg IMAGE={{IMAGE}} -f debian-bookworm.dockerfile .
    docker run --platform "{{PLATFORM}}" --rm -v $(pwd)/patches:/patches -v $(pwd)/dist:/dist "debian-patch" patch.sh

# patch all mosquitto packages
patch-all:
    just PLATFORM=linux/arm/v5 patch-debian
    just PLATFORM=linux/arm/v7 patch-debian
    just PLATFORM=linux/arm64 patch-debian
    just PLATFORM=linux/amd64 patch-debian
