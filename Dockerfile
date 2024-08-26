# Build Stage
FROM debian:12.6 AS build

LABEL maintainer="Amina Waddiz (@0xawaz)"

ENV BITCOIN_VERSION=25.0
ENV PLATFORM_ARCH=x86_64-linux-gnu
ENV TMPDIR="/tmp/bitcoin_verify_binaries"
ENV BITCOIN_DIR=/opt/bitcoin

RUN apt-get update && \
    mkdir -p "$TMPDIR" && chmod 1777 /tmp && \
    apt-get install -y coreutils perl-modules-5.36 && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates && \
    dpkg --configure -a && apt-get install -f && \
    apt-get install -y ca-certificates wget tar gnupg python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR $BITCOIN_DIR

RUN wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/verify-binaries/verify.py && \
    gpg --keyserver hkps://keys.openpgp.org --recv-keys \
    A5E0907A0380E6C3 9B79B45691DB4173 17565732E08E5E41 D7CC770B81FD22A8 1C2491FFEB0EF770 2EEB9F5CC09526C1 \
    BA03F4DBE0C63FB4 8E4256593F177720 410108112E7EA81F D11BD4F33F1DB499 1E4AED62986CD25D C2371D91CB716EA7 && \
    python3 verify.py --min-good-sigs 6 pub "${BITCOIN_VERSION}-linux" && \
    tar -xzvf "${TMPDIR}.${BITCOIN_VERSION}-linux/bitcoin-${BITCOIN_VERSION}-${PLATFORM_ARCH}.tar.gz" --strip-components=1 -C "$BITCOIN_DIR" && \
    rm -rf "$TMPDIR"

# Runtime Stage
FROM --platform=$TARGETPLATFORM debian:12.6 AS runtime

ARG TARGETPLATFORM
ARG UID=101
ARG GID=101

ENV BITCOIN_VERSION=25.0
ENV BITCOIN_DATA=/home/bitcoin/.bitcoin
ENV BITCOIN_DIR=/opt/bitcoin
ENV PATH="${BITCOIN_DIR}/bin:$PATH"

WORKDIR $BITCOIN_DIR

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gosu passwd && \
    groupadd --gid ${GID} bitcoin && \
    useradd --create-home --no-log-init -u ${UID} -g ${GID} bitcoin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build $BITCOIN_DIR .

COPY scripts/start-bitcoin.sh .
RUN chmod +x start-bitcoin.sh

VOLUME ["$BITCOIN_DATA"]

EXPOSE 8332 8333 18332 18333 18443 18444 38332 38333

CMD ["./start-bitcoin.sh"]
