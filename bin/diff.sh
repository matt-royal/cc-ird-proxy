#!/usr/bin/env bash

set -e

BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TOKEN=`$BIN_DIR/token.sh`
cc_url=$(bin/cf_api.sh)
PROXIED_RESPONSE=$(curl -H "Authorization:$TOKEN" -H "CC:$cc_url" http://localhost:4567$1 2>/dev/null)
UNPROXIED_RESPONSE=$(curl -H "Authorization:$TOKEN" ${cc_url}$1 2>/dev/null)

mkdir -p tmp
echo $PROXIED_RESPONSE | $BIN_DIR/prettify_hash.rb > tmp/proxied.json
echo $UNPROXIED_RESPONSE | $BIN_DIR/prettify_hash.rb > tmp/unproxied.json

diff -y tmp/proxied.json tmp/unproxied.json

green="\033[32m"
red="\033[31m"
neutral="\033[0m"

if [ $? -eq 0 ]; then
  printf "${green}EXACT MATCH${neutral}\n"
  exit 0
else
  printf "${red}DIFFERENCES FOUND${neutral}\n"
  exit 1
fi
