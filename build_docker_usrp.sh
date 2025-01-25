#!/usr/bin/env bash
set -o errexit

# travel to the location of the build script
cd $(dirname ${BASH_SOURCE[0]})

docker build \
    --build-arg HTTP_PROXY=http://192.168.75.189:7890 \
    --build-arg HTTPS_PROXY=http://192.168.75.189:7890 \
    --network host \
    --tag usrp-docker \
    .
