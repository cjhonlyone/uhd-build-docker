#!/bin/bash
docker run -it --rm \
    --mount source=xilinx-2021.1,target=/tools/Xilinx \
    --volume /mnt/windows_share:/work:ro \
    usrp-docker \
    bash
