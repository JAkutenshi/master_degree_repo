FROM ubuntu:16.04
MAINTAINER JAkutenshi <jakutenshi@gmail.com>

WORKDIR /root/
ADD vim_setup.tar.gz /root/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    locales          \
    lsb-release      \
    ranger           \
    htop             \
    vim              \
    git              \
    tmux             \
    ssh              \
    xorg             \
    xauth            \
    build-essential  \
    cmake            \
    libxml2-dev       \
    libboost-all-dev \
    pkg-config

RUN locale-gen en_US.UTF-8 ru_RU.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

EXPOSE 22

