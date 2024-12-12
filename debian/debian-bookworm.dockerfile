FROM docker.io/library/debian:bookworm

RUN apt-get update \
    && apt-get install -y ca-certificates

COPY debian-bookworm.sources /etc/apt/sources.list.d/
RUN set -ex \
    && sed -i -- 's/Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install -y \
        build-essential \
        devscripts

COPY patch.sh /usr/bin/

VOLUME [ "/dist" ]
VOLUME [ "/patches" ]
