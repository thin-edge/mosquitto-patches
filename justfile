IMAGE := "debian-12"
IMAGE_FILE := IMAGE + ".dockerfile"
PLATFORM := "linux/arm/v7"

setup:
    docker run --privileged --rm tonistiigi/binfmt --install all
    mkdir -p dist

# Patch existing debian dpkg files and use docker instead of cross compiling
patch-debian:
    #!/usr/bin/env bash
    set -e
    cd debian
    mkdir -p dist/
    docker buildx build --load --platform "{{PLATFORM}}" -t "{{IMAGE}}" -f "{{IMAGE_FILE}}" .
    docker run --platform "{{PLATFORM}}" --rm -v $(pwd)/patches:/patches -v $(pwd)/dist:/dist -v $(pwd)/patch.sh:/usr/bin/patch.sh "{{IMAGE}}" patch.sh
