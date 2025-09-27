FROM ubuntu:24.04

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

USER ubuntu

COPY entrypoint.sh /entrypoint.sh

WORKDIR /home/ubuntu

ENTRYPOINT ["/entrypoint.sh"]

