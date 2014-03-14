#!/usr/bin/env bash

cf auth admin admin 2>&1 1>/dev/null
cat ~/.cf/config.json | ruby -r 'json' -e "print JSON.parse(STDIN.read)['AccessToken']"
