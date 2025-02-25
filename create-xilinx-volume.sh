#!/usr/bin/env bash
set -o errexit

function print_usage() {
    echo "
Usage:
    $(basename $0) [OPTION]

Description:
    Script creates a docker volume with the Xilinx Vivado tools installed
    within. The volume can then be mounted to a docker container when run.

Options:
    -f    Xilinx install archive file
    -h    Print this help info
"
}


# FILE=Xilinx_*.tar.gz
# while getopts 'hf:' x; do
#     case "$x" in
#         f) FILE="${OPTARG}";;
#         h) print_usage; exit 2 ;;
#         ?) print_usage; exit 2 ;;
#     esac
# done


# unpack xilinx tools after downloading them
# test -e Xilinx && rm -rf Xilinx
# mkdir Xilinx
# tar zxvf $FILE -C Xilinx --strip-components 1

# delete volume if exists
docker volume rm xilinx-2021.1 &> /dev/null || echo "no already existing volume"

# create empty docker volume to install xilinx into
docker volume create xilinx-2021.1 &> /dev/null

# create command used to install Vivado into newly created volume
CMD="./xsetup -a XilinxEULA,3rdPartyEULA,WebTalkTerms -b Install -c ../install_config.txt \
    && ln -s /tools/Xilinx/Vivado/2021.1/settings64.sh /tools/Xilinx/"

# mount empty volume
docker run \
    --tty \
    --rm \
    --mount source=xilinx-2021.1,target=/tools/Xilinx \
    --volume $PWD:/work:rw \
    --workdir "/work" \
    ubuntu:20.04 \
    /bin/bash -c "cd 2021.1 && ${CMD}"
