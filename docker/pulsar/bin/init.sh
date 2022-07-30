#!/usr/bin/env bash

# shellcheck disable=SC2155
export IP=$(ifconfig|grep "inet "|grep -v 127.0.0.1|tail -1|awk '{ print $2 }')
export PULSAR_PROMETHEUS_URL=http://"$IP":9090

CSRF_TOKEN=$(curl http://127.0.0.1:7750/pulsar-manager/csrf-token)

curl \
    -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
    -H "Cookie: XSRF-TOKEN=$CSRF_TOKEN;" \
    -H 'Content-Type: application/json' \
    -X PUT http://127.0.0.1:7750/pulsar-manager/users/superuser \
    -d '{"name": "admin", "password": "apachepulsar", "description": "test", "email": "admin@pulsar.apache.org"}'

docker exec -it pulsar_pulsar_1 /pulsar/bin/pulsar-admin clusters update standalone --url http://"$IP":8080