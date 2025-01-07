#!/bin/bash

set -ex

# Grab the container's IP address
IPADDRESS="$(ip address | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')"

cd /opt/cobaltstrike

# 1) Always download / update
token=$(curl -s https://download.cobaltstrike.com/download \
           -d "dlkey=${COBALTSTRIKE_KEY}" \
       | grep 'href="/downloads/' | cut -d '/' -f3)

curl -s https://download.cobaltstrike.com/downloads/"${token}"/latest410/cobaltstrike-dist-linux.tgz \
     -o /tmp/cobaltstrike.tgz

tar zxf /tmp/cobaltstrike.tgz -C /opt

# 2) Always update using the license key
echo "${COBALTSTRIKE_KEY}" | /opt/cobaltstrike/update

# 3) Finally run the teamserver
/opt/cobaltstrike/teamserver \
    "$IPADDRESS" \
    "${COBALTSTRIKE_PASS}" \
    "/opt/cobaltstrike/${COBALTSTRIKE_PROFILE}" \
    "${COBALTSTRIKE_EXP}"
