#!/usr/bin/env bash

set -e

dc_exec="docker compose -f docker-compose.yml exec"

$dc_exec pulsar ./bin/pulsar-admin tenants create fl-tenant || true
$dc_exec pulsar ./bin/pulsar-admin namespaces create fl-tenant/fl-namespace || true
$dc_exec pulsar ./bin/pulsar-admin namespaces create fl-tenant/fl-algorithm || true

if [ "$1" == "dashboard" ]; then
  # shellcheck disable=SC2155
  export IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | tail -1 | awk '{ print $2 }')
  export PULSAR_PROMETHEUS_URL=http://"$IP":9090

  CSRF_TOKEN=$(curl http://127.0.0.1:7750/pulsar-manager/csrf-token)

  curl \
    -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
    -H "Cookie: XSRF-TOKEN=$CSRF_TOKEN;" \
    -H 'Content-Type: application/json' \
    -X PUT http://127.0.0.1:7750/pulsar-manager/users/superuser \
    -d '{"name": "admin", "password": "apachepulsar", "description": "test", "email": "admin@pulsar.apache.org"}'

  $dc_exec -it pulsar /pulsar/bin/pulsar-admin clusters update standalone --url http://"$IP":8080
fi
