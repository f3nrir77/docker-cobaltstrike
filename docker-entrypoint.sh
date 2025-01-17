#!/bin/bash

set -ex

# Grab the container's IP address
IPADDRESS="$(ip address | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')"

cd /opt/cobaltstrike

# Check if we already downloaded CS teamserver or do we grab a fresh copy
FILE=/opt/cobaltstrike/cs-download-check

if [ -f "$FILE" ]; then
    # The important part here is that we cd into /opt/cobaltstrike/server 
    # so the teamserver script finds its support files
    cd /opt/cobaltstrike/server
    ./teamserver \
        "$IPADDRESS" \
        "${COBALTSTRIKE_PASS}" \
        "/opt/cobaltstrike/${COBALTSTRIKE_PROFILE}" \
        "${COBALTSTRIKE_EXP}"
else
    # Mark that we've downloaded (and update) once
    touch /opt/cobaltstrike/cs-download-check

    # 1) Always download / update
    token=$(curl -s https://download.cobaltstrike.com/download \
                -d "dlkey=${COBALTSTRIKE_KEY}" \
            | grep 'href="/downloads/' | cut -d '/' -f3)

    curl -s https://download.cobaltstrike.com/downloads/"${token}"/latest410/cobaltstrike-dist-linux.tgz \
         -o /tmp/cobaltstrike.tgz

    tar zxf /tmp/cobaltstrike.tgz -C /opt

    # 2) Always update using the license key
    echo "${COBALTSTRIKE_KEY}" | /opt/cobaltstrike/update

    # 3) Finally run the teamserver from its own directory
    cd /opt/cobaltstrike/server
    ./teamserver \
        "$IPADDRESS" \
        "${COBALTSTRIKE_PASS}" \
        "/opt/cobaltstrike/${COBALTSTRIKE_PROFILE}" \
        "${COBALTSTRIKE_EXP}"
fi
