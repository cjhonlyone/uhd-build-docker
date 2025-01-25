#!/bin/bash
docker run -it \
    --rm \
    -e HTTP_PROXY=http://192.168.75.189:7890 \
    -e HTTPS_PROXY=http://192.168.75.189:7890 \
    --mount source=xilinx-2021.1,target=/tools/Xilinx \
    --volume $(pwd)/work:/work:rw \
    -e HOST_USER_ID=$(id -u) \
    --network host \
    usrp-docker \
    bash

