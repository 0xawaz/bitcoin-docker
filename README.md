# Docker for Bitcoin Core

This project aims to enable more automation around running a bitcoin node.

## Pre-Requisites

This project is focused on Unix-like environments. Please contact [0xawaz](https://t.me/oxawaz) if you need a Windows setup or any other specific environment.

Make sure you have docker and docker-compose [installed](https://docs.docker.com/engine/install/).

## Usage

### Docker

```bash
# setup environment
git clone --branch 0xawaz_docker --single-branch git@github.com:0xawaz/bitcoin.git
cd bitcoin/contrib/docker
./scripts/setup-env.sh

# populate env vars
source .env

# build bitcoin-core docker image
docker build -t 0xawaz/bitcoin-core:$VERSION .

# run and test my bitcoin-core container
docker run --platform linux/amd64 --rm -it 0xawaz/bitcoin-core:$VERSION /btc/bin/bitcoind -version
```

### Docker Compose

Coming Soon ...
