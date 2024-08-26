# Stage 1: Build Stage
FROM --platform=$BUILDPLATFORM debian:12.6-slim AS build

LABEL maintainer.0="Amina (@0xawaz)"

# Set the environment variables for UID and GID
ARG UID=101
ARG GID=101

WORKDIR /btc

# Set Variables
ENV PLATFORM_ARCH=x86_64-linux-gnu
ENV BITCOIN_VERSION=25.0
ENV TMPDIR="/tmp/bitcoin_verify_binaries"

# Update package list and install necessary packages for building
RUN apt-get update && \
    apt-get install -y wget tar gnupg python3 ca-certificates --no-install-recommends --fix-missing || true && \
    dpkg --configure -a && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Download Binary and Verify Signatures and Hashes
RUN wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/verify-binaries/verify.py && \
    gpg --keyserver hkps://keys.openpgp.org --recv-keys \
    A5E0907A0380E6C3 9B79B45691DB4173 17565732E08E5E41 D7CC770B81FD22A8 1C2491FFEB0EF770 2EEB9F5CC09526C1 \
    BA03F4DBE0C63FB4 8E4256593F177720 410108112E7EA81F D11BD4F33F1DB499 1E4AED62986CD25D C2371D91CB716EA7 && \
    python3 verify.py --min-good-sigs 6 pub "${BITCOIN_VERSION}-linux" && \
    tar -xzvf "${TMPDIR}.${BITCOIN_VERSION}-linux/bitcoin-${BITCOIN_VERSION}-${PLATFORM_ARCH}.tar.gz" --strip-components=1 -C /btc && \
    rm -rf $TMPDIR

# Stage 2: Runtime Stage
FROM --platform=$TARGETPLATFORM debian:12.6-slim

# Set the environment variables for UID and GID
ARG UID=101
ARG GID=101

WORKDIR /btc

# Install only the necessary runtime dependencies
RUN apt-get update && \
    apt-get install -y gosu passwd --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create the group and user
RUN groupadd --gid ${GID} bitcoin && \
    useradd --create-home --no-log-init -u ${UID} -g ${GID} bitcoin

# Copy Bitcoin Core binaries from the build stage
COPY --from=build /btc /btc

# Copy the startup script into the container
COPY scripts/start-bitcoin.sh /btc/
RUN chmod +x /btc/start-bitcoin.sh

# Set the PATH and Bitcoin data directory
ENV PATH=/btc/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV BITCOIN_DATA=/root/.bitcoin

# Expose the necessary ports
EXPOSE 18332 18333 18443 18444 38332 38333 8332 8333

# Set the command to run the startup script
CMD ["/btc/start-bitcoin.sh"]
