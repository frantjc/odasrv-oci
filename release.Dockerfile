FROM debian:stable-slim AS release
ARG ODAMEX_VERSION=11.1.0
ADD https://github.com/odamex/odamex/releases/download/${ODAMEX_VERSION}/odamex-src-${ODAMEX_VERSION}.tar.gz /tmp/
RUN mkdir /src \
    && tar -zxvf /tmp/odamex-src-${ODAMEX_VERSION}.tar.gz -C /src

FROM debian:stable-slim
ARG ODAMEX_VERSION=11.1.0
ENV ODAMEX_VERSION=${ODAMEX_VERSION}
COPY --from=release /src/odamex-src-${ODAMEX_VERSION} /src/odamex-src-${ODAMEX_VERSION}
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        git \
        zlib1g-dev \
        libzstd-dev \
    && cd /src/odamex-src-${ODAMEX_VERSION} \
    && cmake \
        -DBUILD_CLIENT=0 \
        -DBUILD_SERVER=1 \
        -DBUILD_LAUNCHER=0 \
        -DBUILD_MASTER=0 \
        -DBUILD_OR_FAIL=1 \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_C_COMPILER=gcc \
        -DCMAKE_C_FLAGS="-O2 -w" \
        -DCMAKE_CXX_COMPILER=g++ \
        -DCMAKE_CXX_FLAGS="-O2 -w" \
        -DCMAKE_INSTALL_PREFIX=/usr/local . \
        -DZLIB_INCLUDE_DIR=/usr/include \
    && make -j$(nproc) odasrv install \
    && rm -rf /src \
    && apt-get remove -y \
        build-essential \
        cmake \
        zlib1g-dev \
        libzstd-dev \
    && apt-get install -y --no-install-recommends \
        zlib1g \
        libzstd1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system odamex \
    && useradd --system --gid odamex --shell /bin/bash --create-home odamex
USER odamex
ENTRYPOINT ["/usr/local/bin/odasrv"]
