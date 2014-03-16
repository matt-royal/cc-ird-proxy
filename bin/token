#!/usr/bin/env bash

cf auth $CF_USER $CF_PASSWORD 2>&1 1>/dev/null
cat ~/.cf/config.json | ruby -r 'json' -e "print JSON.parse(STDIN.read)['AccessToken']"
