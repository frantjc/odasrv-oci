FROM debian:stable-slim
ARG ODAMEX_VERSION=10.6.0
ENV ODAMEX_VERSION=${ODAMEX_VERSION}
ADD https://github.com/odamex/odamex/releases/download/${ODAMEX_VERSION}/odamex-src-${ODAMEX_VERSION}.tar.gz /src/
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        deutex \
        zlib1g-dev \
    && cd /src \
    && tar -zxvf /src/odamex-src-${ODAMEX_VERSION}.tar.gz \
    && cd /src/odamex-src-${ODAMEX_VERSION} \
    && cmake \
        -DBUILD_CLIENT=0 \
        -DBUILD_SERVER=1 \
        -DBUILD_LAUNCHER=0 \
        -DBUILD_MASTER=0 \
        -DBUILD_OR_FAIL=1 \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_INSTALL_PREFIX=/usr/local . \
    && make -j$(nproc) odasrv install \
    && rm -rf /src \
    && apt-get remove -y \
        build-essential \
        cmake \
        deutex \
        zlib1g-dev \
    && apt-get install -y --no-install-recommends \
        zlib1g \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system odamex \
    && useradd --system --gid odamex --shell /bin/bash --create-home odamex
USER odamex
ENTRYPOINT ["/usr/local/bin/odasrv"]
