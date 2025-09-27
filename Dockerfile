# Container image that runs your code
FROM ubuntu:22.04

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

USER user

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]

