FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y ca-certificates

COPY debian-bookworm.sources /etc/apt/sources.list.d/
RUN set -ex \
    && sed -i -- 's/Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        cdbs \
        devscripts \
        equivs \
        fakeroot \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/*
