#!/bin/bash

# retrieve rpcuser and rpcpassword from environment
RPCUSER=$BITCOIN_RPCUSER
RPCPASSWORD=$BITCOIN_RPCPASSWORD

# Write dynamic values to bitcoin.conf
cat <<EOF > /root/.bitcoin/bitcoin.conf
server=1
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=0.0.0.0/0
rpcbind=0.0.0.0:8332
rpcport=8332
EOF

# Start the Bitcoin daemon
/btc/bin/bitcoind -conf=/root/.bitcoin/bitcoin.conf
