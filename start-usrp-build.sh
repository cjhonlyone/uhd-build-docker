#!/bin/bash

# xhost +local:root

docker run -dit \
    --name usrp_build \
    --memory=32g \
    --cpus=8 \
    -e HTTP_PROXY=http://192.168.75.189:7890 \
    -e HTTPS_PROXY=http://192.168.75.189:7890 \
    --mount source=xilinx-2021.1,target=/tools/Xilinx \
    --volume $(pwd)/work:/work:rw \
    -u $(id -u):$(id -g) \
    --network host \
    -v /etc/localtime:/etc/localtime:ro \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    usrp-docker \
    bash

