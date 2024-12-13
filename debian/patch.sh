#!/bin/sh
# * https://unix.stackexchange.com/questions/324680/how-to-apply-a-patch-in-a-debian-package
set -e

mkdir -p /tmp/mosquitto
cd /tmp/mosquitto

patch_mosquitto() {
    PACKAGE="mosquitto"
    # download source for a package
    apt-get source "$PACKAGE"

    # apply patches
    SRC_DIR=$(find . -maxdepth 1 -type d -name "${PACKAGE}-*" | head -n1)
    cd "$SRC_DIR"
    cp /patches/fix-session-handling.patch ./debian/patches/
    patch -p1 < /patches/fix-session-handling.patch

    export EMAIL=info@thin-edge.io
    dch -n "Apply session persistence using per_listener_settings #2618"

    EDITOR=/bin/true dpkg-source -q --commit . "fix-session-handling-when-per_listener_settings"

    echo "Installing build dependencies"
    apt-get build-dep -y "$PACKAGE"

    echo "Build the package"
    dpkg-buildpackage -us -uc

    echo "List rebuilt packages"
    ls -l ../*.deb

    mkdir -p /dist
    cp ../*.deb /dist/
}

patch_mosquitto
