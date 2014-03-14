#!/usr/bin/env bash

function do_diff() {
  printf "== Diffing ${1}?inline-relations-depth=1...  "

  bin/diff.sh "${1}?inline-relations-depth=1"

  printf "== Diffing ${1}?inline-relations-depth=2...  "

  bin/diff.sh "${1}?inline-relations-depth=2"
}

do_diff '/v2/apps'
do_diff '/v2/services'
do_diff '/v2/service_plans'
do_diff '/v2/service_instances'
do_diff '/v2/service_bindings'
# do_diff '/v2/service_brokers'
do_diff '/v2/service_auth_tokens'
do_diff '/v2/routes'
do_diff '/v2/domains'
# do_diff '/v2/jobs'
# do_diff '/v2/quota_definitions'
do_diff '/v2/spaces'
# do_diff '/v2/users'

echo "********************************************************************************"
echo " DONE"

