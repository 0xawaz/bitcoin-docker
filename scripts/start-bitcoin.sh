#!/bin/bash

# retrieve rpcuser and rpcpassword from environment
RPCUSER=$BITCOIN_RPCUSER
RPCPASSWORD=$BITCOIN_RPCPASSWORD

# Write dynamic values to bitcoin.conf
cat <<EOF > /home/bitcoin/.bitcoin/bitcoin.conf
server=1
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=0.0.0.0/0
rpcbind=0.0.0.0:8332
rpcport=8332
EOF

# Start the Bitcoin daemon
/opt/bitcoin/bin/bitcoind -conf=/home/bitcoin/.bitcoin/bitcoin.conf
