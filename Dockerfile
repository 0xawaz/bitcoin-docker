# Stage 1: Build Stage
FROM --platform=amd64 debian:12.6-slim AS build

LABEL maintainer=0xawaz

# Set the environment variables for UID and GID
ARG UID=101
ARG GID=101

# Set Bitcoin Core version
ENV BITCOIN_VERSION=25.0

WORKDIR /btc

# Update package list and install necessary packages for building
RUN apt-get update && \
    apt-get install -y wget tar gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and extract Bitcoin Core binaries
RUN wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz && \
    tar -xzvf bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz --strip-components=1 -C /btc && \
    rm bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz

# Stage 2: Runtime Stage
FROM --platform=amd64 debian:12.6-slim

LABEL maintainer=0xawaz

# Set the environment variables for UID and GID
ARG UID=101
ARG GID=101

WORKDIR /btc

# Install only the necessary runtime dependencies
RUN apt-get update && \
    apt-get install -y gosu passwd && \
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
