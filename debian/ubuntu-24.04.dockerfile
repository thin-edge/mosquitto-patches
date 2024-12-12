FROM ubuntu:24.04

RUN set -ex \
    && sed -i -- 's/Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/ubuntu.sources \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        build-essential \
        cdbs \
        devscripts \
        equivs \
        fakeroot \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/*
