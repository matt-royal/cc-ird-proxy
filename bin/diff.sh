#!/usr/bin/env bash

set -e

BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TOKEN=`$BIN_DIR/token.sh`

PROXIED_RESPONSE=$(curl -H "Authorization:$TOKEN" http://localhost:4567$1 2>/dev/null)
UNPROXIED_RESPONSE=$(curl -H "Authorization:$TOKEN" http://api.10.244.0.34.xip.io$1 2>/dev/null)

mkdir -p tmp
echo $PROXIED_RESPONSE | $BIN_DIR/prettify_hash.rb > tmp/proxied.json
echo $UNPROXIED_RESPONSE | $BIN_DIR/prettify_hash.rb > tmp/unproxied.json

diff -y tmp/proxied.json tmp/unproxied.json
