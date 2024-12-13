set dotenv-load

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
    mkdir -p "dist/{{IMAGE}}"
    docker buildx build --load --platform "{{PLATFORM}}" -t "{{IMAGE}}" -f "{{IMAGE_FILE}}" .
    docker run --platform "{{PLATFORM}}" --rm -v $(pwd)/patches:/patches -v $(pwd)/dist/{{IMAGE}}:/dist -v $(pwd)/patch.sh:/usr/bin/patch.sh "{{IMAGE}}" patch.sh

# publish debian packages to linux repo
publish-debian:
    ./ci/publish.sh --path debian/dist
