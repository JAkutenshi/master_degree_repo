FROM jakutenshi/ubuntu-orocos-toolchain-2.8-16.04:manual

# Step 1
# RUN git config --global user.name "Your_name"
# RUN git config --global user.email yourname@yourmail.com
# RUN apt-get update
# RUN apt-get install -y ruby-dev bundler clang
# RUN git clone https://github.com/orocos-toolchain/build.git
# WORKDIR build/
# RUN git checkout toolchain-2.8-16.04

# Step 2-3
WORKDIR /root/
ADD orocos-before-update.tar.gz /root/

# Step 4
WORKDIR /root/orocos
RUN echo "source /root/orocos/env.sh" >> ~/.bashrc
RUN /bin/bash -c ". env.sh && autoproj update && autoproj build"

# Clear workspace
RUN rm -rf /root/build/ && rm /root/manual_from_step_2.md

WORKDIR /root/
