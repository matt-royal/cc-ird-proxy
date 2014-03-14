#!/usr/bin/env bash

set -e

mkdir -p tmp
PROXIED_RESPONSE=$(bin/curl_proxy.sh $1 2>/dev/null)
echo $PROXIED_RESPONSE   | bin/prettify_hash.rb > tmp/proxied.json

UNPROXIED_RESPONSE=$(bin/curl_cc.sh $1 2>/dev/null)
echo $UNPROXIED_RESPONSE | bin/prettify_hash.rb > tmp/unproxied.json

green="\e[32m"
red="\e[31m"
reset="\e[0m"

set +e

if (diff tmp/proxied.json tmp/unproxied.json 2>&1 >/dev/null); then
  printf "${green}EXACT MATCH${reset}\n"
  exit 0
else
  printf "${red}DIFFERENCES FOUND:${reset}\n"
  if (which colordiff); then
    colordiff -y tmp/proxied.json tmp/unproxied.json
  else
    diff -y tmp/proxied.json tmp/unproxied.json
  fi
  printf "\n"
  exit 1
fi
