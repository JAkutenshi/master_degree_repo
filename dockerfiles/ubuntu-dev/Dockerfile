FROM ubuntu:latest
MAINTAINER JAkutenshi <jakutenshi@gmail.com>

ADD ./.vimrc /root/
RUN mkdir -p /root/.vim/swap
RUN mkdir -p /root/.vim/backup
RUN mkdir -p /root/.vim/colors
RUN mkdir -p /root/.vim/after/syntax
ADD ./monokai.vim /root/.vim/colors
ADD ./c.vim /root/.vim/after/syntax
ADD ./cpp.vim /root/.vim/after/syntax

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    locales          \
    lsb-release      \
    ranger           \
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
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

EXPOSE 22

WORKDIR /root/
