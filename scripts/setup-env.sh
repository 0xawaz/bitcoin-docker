#!/bin/bash


# generate dynamic rpcuser and rpcpassword or retrieve from environment
BITCOIN_RPCUSER=${BITCOIN_RPCUSER:-btc$(date +%s | cut -c 7-10)}
BITCOIN_RPCPASSWORD=${BITCOIN_RPCPASSWORD:-$(openssl rand -hex 32)}

# substitute both variables in one step and create .env from .env-example
sed -e "s/your-rpc-user/${BITCOIN_RPCUSER}/" -e "s/your-rpc-password/${BITCOIN_RPCPASSWORD}/" .env-example > .env
