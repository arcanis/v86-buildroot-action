FROM ubuntu:24.04

WORKDIR /root

RUN apt-get update && apt-get install -y \
    bash \
    bc \
    build-essential \
    cpio \
    curl \
    file \
    git \
    libncurses-dev \
    python3 \
    python3-pip \
    rsync \
    unzip \
    wget

COPY config-buildroot.txt config-buildroot.txt
COPY config-linux.txt config-linux.txt
COPY entrypoint.sh entrypoint.sh
COPY post-build.sh post-build.sh
COPY rootfs-overlay rootfs-overlay

ENTRYPOINT ["./entrypoint.sh"]
