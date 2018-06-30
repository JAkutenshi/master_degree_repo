FROM jakutenshi/ubuntu-yarp:latest

ADD ./benchmark.tar.gz /root/
WORKDIR /root/benchmark/build
RUN cmake .. -DCMAKE_BUILD_TYPE=RELEASE -DBENCHMARK_ENABLE_TESTING=OFF && \
    make && \
    make install

WORKDIR /root/
RUN rm -rf /root/benchmark/
