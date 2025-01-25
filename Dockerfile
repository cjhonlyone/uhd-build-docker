FROM ubuntu:20.04

RUN sed -i s:/archive.ubuntu.com:/mirrors.tuna.tsinghua.edu.cn/ubuntu:g /etc/apt/sources.list
RUN cat /etc/apt/sources.list
RUN apt-get clean
RUN apt-get -y update --fix-missing

# Update Ubuntu
RUN set -eux; apt-get update -y \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/list* /tmp/* /var/tmp/*

# Install docker in the docker image
RUN set -eux; apt-get update -y \
    && BUILD_DEPS='curl gnupg apt-transport-https ca-certificates' \
    && apt-get install -y $BUILD_DEPS --no-install-recommends \
    && curl -fsSL https://get.docker.com | sh - \
    && apt-get purge -y --auto-remove $BUILD_DEPS \
    && apt-get purge -y --auto-remove docker-ce-rootless-extras docker-scan-plugin docker-ce \
    && rm -rf /usr/libexec/docker/ \
    && rm /etc/apt/sources.list.d/docker.list \
    && rm -rf /var/lib/apt/list* /tmp/* /var/tmp/*

# Setup sudo for users
RUN set -eux; apt-get update -y \
    && apt-get install -y sudo --no-install-recommends \
    && echo 'Defaults lecture = never' >> /etc/sudoers \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && rm -rf /var/lib/apt/list* /tmp/* /var/tmp/*

# Vivado dependency
RUN set -eux; apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y locales libncurses5 libtinfo5 libncurses5-dev libncursesw5-dev libxrender1 libxtst6 libxi6 libfreetype6 libfontconfig1 --no-install-recommends \
    && locale-gen "en_US.UTF-8" \
    && rm -rf /var/lib/apt/list* /tmp/* /var/tmp/*

# libuhd-dev applications dependencies
RUN set -eux; apt-get update -y \
    && apt-get upgrade -y \
    && apt-get -y install -y python3 pip git vim bash build-essential doxygen \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install autoconf automake build-essential ccache cmake cpufrequtils doxygen ethtool \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install g++ git inetutils-tools libboost-all-dev libncurses5 libncurses5-dev libusb-1.0-0 libusb-1.0-0-dev \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install libusb-dev python3-dev python3-mako python3-numpy python3-requests python3-scipy python3-setuptools python3-ruamel.yaml \
    && locale-gen "en_US.UTF-8" \
    && rm -rf /var/lib/apt/list* /tmp/* /var/tmp/*

# Install tool to run as user within docker
RUN set -eux; apt-get update -y \
    && apt-get install -y gosu screen strace net-tools lsof iotop curl lsb-core \
    && gosu nobody true \
    && rm -rf /var/lib/apt/list* /tmp/* /var/tmp/*

RUN useradd --create-home --no-log-init --shell /bin/bash user\
&& adduser user sudo \
&& echo 'user:password' | chpasswd

RUN echo 'source /tools/Xilinx/Vivado/2021.1/settings64.sh' >> /home/user/.bashrc && \
    echo 'source /tools/Xilinx/Vitis_HLS/2021.1/settings64.sh' >> /home/user/.bashrc && \
    echo 'source /tools/Xilinx/Vitis/2021.1/settings64.sh' >> /home/user/.bashrc && \
    echo 'export XILINX_PATH=/tools/Xilinx/vivado-patch-AR76780/vivado' >> /home/user/.bashrc && \
    echo 'export XILINXD_LICENSE_FILE=/tools/Xilinx/license' >> /home/user/.bashrc && \
    echo 'export XILINX_LOCAL_USER_DATA=/tools/Xilinx/.xilinx' >> /home/user/.bashrc && \
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/work/libuhd-build/lib' >> /home/user/.bashrc && \
    echo 'export PATH=$PATH:/work/libuhd-build/bin' >> /home/user/.bashrc && \
    echo 'export PYTHONPATH=/work/libuhd-build/lib/python3.8/site-packages:$PYTHONPATH' >> /home/user/.bashrc

RUN USER=user && \
    GROUP=docker && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4.1/fixuid-0.4.1-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

USER user:docker
ENTRYPOINT ["fixuid"]

# COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh

# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
