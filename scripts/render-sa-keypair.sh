#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`

if [[ ! -f ${SA_KEY} ]]; then
    openssl genrsa -out "${SA_KEY}" 4096
    openssl rsa -pubout -in "${SA_KEY}" -out "${SA_PUB_KEY}"
fi
