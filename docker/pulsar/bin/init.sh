#!/usr/bin/env bash

# shellcheck disable=SC2155
export PULSAR_PROMETHEUS_URL=http://$(ifconfig|grep "inet "|grep -v 127.0.0.1|tail -1|awk '{ print $2 }'):9090

CSRF_TOKEN=$(curl http://127.0.0.1:7750/pulsar-manager/csrf-token)

curl \
    -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
    -H "Cookie: XSRF-TOKEN=$CSRF_TOKEN;" \
    -H 'Content-Type: application/json' \
    -X PUT http://127.0.0.1:7750/pulsar-manager/users/superuser \
    -d '{"name": "admin", "password": "apachepulsar", "description": "test", "email": "admin@pulsar.apache.org"}'