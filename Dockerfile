FROM debian

RUN apt-get update -y
RUN apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        deutex \
        zlib1g-dev

ARG ODAMEX_VERSION=10.4.0
ENV ODAMEX_VERSION=${ODAMEX_VERSION}

ADD https://github.com/odamex/odamex/releases/download/${ODAMEX_VERSION}/odamex-src-${ODAMEX_VERSION}.tar.gz /src/
RUN cd /src \
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
    && make -j$(nproc) odasrv install

RUN apt-get remove -y \
        build-essential \
        cmake \
        deutex \
        zlib1g-dev \
    && apt-get install -y --no-install-recommends \
        zlib1g \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /src

ARG UID=101
ARG GID=101

RUN groupadd --gid $GID odamex \
    && useradd --uid $UID --gid odamex --shell /bin/bash --create-home -d /odamex odamex

USER odamex

ENTRYPOINT ["/usr/local/bin/odasrv"]
