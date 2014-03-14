#!/usr/bin/env bash

curl -m 300 -H "Authorization:$(bin/token.sh)" -H "CC:$(bin/cf_api.sh)" http://localhost:9292$1
