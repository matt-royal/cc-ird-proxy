#!/usr/bin/env bash

curl -m 65 -H "Authorization:$(bin/token.sh)" $(bin/cf_api.sh)$1
