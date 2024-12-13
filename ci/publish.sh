#!/usr/bin/env bash
set -e
# -----------------------------------------------
# Publish package to Cloudsmith.io
# -----------------------------------------------
help() {
  cat <<EOF
Publish packages from a path to a package repository

All the necessary dependencies will be downloaded automatically if they are not already present

Usage:
    $0

Flags:
    --token <string>            Debian access token used to authenticate the commands
    --owner <string>            Debian repository owner
    --repo <string>             Name of the debian repository to publish to
    --help|-h                   Show this help

Optional Environment variables (instead of flags)

PUBLISH_TOKEN            Equivalent to --token flag
PUBLISH_OWNER            Equivalent to --owner flag
PUBLISH_REPO             Equivalent to --repo flag

Examples:
    $0 \\
        --token "mywonderfultoken" \\
        --repo "community" \\
        --path ./dist

    \$ Publish all debian/alpine/rpm packages found under ./dist
EOF
}

PUBLISH_TOKEN="${PUBLISH_TOKEN:-}"
PUBLISH_OWNER="${PUBLISH_OWNER:-thinedge}"
PUBLISH_REPO="${PUBLISH_REPO:-tedge-dev}"
SOURCE_PATH="./"

#
# Argument parsing
#
POSITIONAL=()
while [[ $# -gt 0 ]]
do
    case "$1" in
        # Repository owner
        --owner)
            if [ -n "$2" ]; then
                PUBLISH_OWNER="$2"
            fi
            shift
            ;;

        # Token used to authenticate publishing commands
        --token)
            PUBLISH_TOKEN="$2"
            shift
            ;;

        # Where to look for the debian files to publish
        --path)
            SOURCE_PATH="$2"
            shift
            ;;

        # Which debian repo to publish to (under the given host url)
        --repo)
            if [ -n "$2" ]; then
                PUBLISH_REPO="$2"
            fi
            shift
            ;;

        --help|-h)
            help
            exit 0
            ;;
        
        -*)
            echo "Unrecognized flag" >&2
            help
            exit 1
            ;;

        *)
            POSITIONAL+=("$1")
            ;;
    esac
    shift
done
set -- "${POSITIONAL[@]}"

# Add local tools path
LOCAL_TOOLS_PATH="$HOME/.local/bin"
export PATH="$LOCAL_TOOLS_PATH:$PATH"

# Install tooling if missing
if ! [ -x "$(command -v cloudsmith)" ]; then
    echo 'Install cloudsmith cli' >&2
    if command -v pip3 &>/dev/null; then
        pip3 install --upgrade cloudsmith-cli
    elif command -v pip &>/dev/null; then
        pip install --upgrade cloudsmith-cli
    else
        echo "Could not install cloudsmith cli. Reason: pip3/pip is not installed"
        exit 2
    fi
fi


publish() {
    local sourcedir="$1"
    local pattern="$2"
    local package_type="$3"
    local distribution="$4"
    local distribution_version="$5"
    local component="$6"

    if [ ! -d "$sourcedir" ]; then
        echo "Warn: source directory does not exist. path=$sourcedir"
        return 0
    fi

    # Notes: Currently Cloudsmith does not support the following (this might change in the future)
    #  * distribution and distribution_version must be selected from values in the list. use `cloudsmith list distros` to get the list
    find "$sourcedir" -name "$pattern" -print0 | while read -r -d $'\0' file
    do
        repo_target="${PUBLISH_OWNER}/${PUBLISH_REPO}/${distribution}/${distribution_version}"
        echo "Publishing $file to $repo_target" >&2
        cloudsmith upload "$package_type" "$repo_target" "$file" \
            --component "$component" \
            --no-wait-for-sync \
            --api-key "${PUBLISH_TOKEN}"
    done
}

# debian-12 bookworm
publish "$SOURCE_PATH/debian-12-amd64" "*.deb" deb "debian" "bookworm" "tedge-updates"
publish "$SOURCE_PATH/debian-12-arm64" "*.deb" deb "debian" "bookworm" "tedge-updates"
publish "$SOURCE_PATH/debian-12-armel" "*.deb" deb "debian" "bookworm" "tedge-updates"
publish "$SOURCE_PATH/debian-12-armhf" "*.deb" deb "debian" "bookworm" "tedge-updates"

# debian-13 trixie
publish "$SOURCE_PATH/debian-13-amd64" "*.deb" deb "debian" "trixie" "tedge-updates"
publish "$SOURCE_PATH/debian-13-arm64" "*.deb" deb "debian" "trixie" "tedge-updates"
publish "$SOURCE_PATH/debian-13-armel" "*.deb" deb "debian" "trixie" "tedge-updates"
publish "$SOURCE_PATH/debian-13-armhf" "*.deb" deb "debian" "trixie" "tedge-updates"


# ubuntu
publish "$SOURCE_PATH/ubuntu-24.04-amd64" "*.deb" deb "ubuntu" "noble" "tedge-updates"     # 24.04
publish "$SOURCE_PATH/ubuntu-24.04-arm64" "*.deb" deb "ubuntu" "noble" "tedge-updates"     # 24.04
publish "$SOURCE_PATH/ubuntu-24.04-armhf" "*.deb" deb "ubuntu" "noble" "tedge-updates"     # 24.04
