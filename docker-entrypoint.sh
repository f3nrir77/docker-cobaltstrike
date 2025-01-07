#!/bin/bash

set -ex

# Grab the container's IP address
IPADDRESS="$(ip address | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')"

cd /opt/cobaltstrike

# Check if we already downloaded CS teamserver or do we grab a fresh copy
FILE=/opt/cobaltstrike/cs-download-check

if [ -f "$FILE" ]; then
    /opt/cobaltstrike/server/teamserver \
        "$IPADDRESS" \
        "${COBALTSTRIKE_PASS}" \
        "/opt/cobaltstrike/${COBALTSTRIKE_PROFILE}" \
        "${COBALTSTRIKE_EXP}"
else
    # 1) Always download / update
    touch /opt/cobaltstrike/cs-download-check
    token=$(curl -s https://download.cobaltstrike.com/download \
                -d "dlkey=${COBALTSTRIKE_KEY}" \
            | grep 'href="/downloads/' | cut -d '/' -f3)

    curl -s https://download.cobaltstrike.com/downloads/"${token}"/latest410/cobaltstrike-dist-linux.tgz \
         -o /tmp/cobaltstrike.tgz

    tar zxf /tmp/cobaltstrike.tgz -C /opt

    # 2) Always update using the license key
    echo "${COBALTSTRIKE_KEY}" | /opt/cobaltstrike/update

    # 3) Finally run the teamserver
    /opt/cobaltstrike/server/teamserver \
        "$IPADDRESS" \
        "${COBALTSTRIKE_PASS}" \
        "/opt/cobaltstrike/${COBALTSTRIKE_PROFILE}" \
        "${COBALTSTRIKE_EXP}"
fi
