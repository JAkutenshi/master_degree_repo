FROM jakutenshi/ros
MAINTAINER JAkutenshi <jakutenshi@gmail.com>

ADD ./benchmark /root/benchmark
ADD ./googletest /root/googletest

WORKDIR /root/googletest/build
RUN cmake ..
RUN make install

WORKDIR /root/benchmark/build
RUN cmake .. -DCMAKE_BUILD_TYPE=RELEASE
RUN make install

RUN mkdir -p /root/google_examples/bin
RUN mkdir /root/google_examples/src
RUN cp -r /root/benchmark/test/* /root/google_examples/src/
RUN cp -r /root/benchmark/build/test/* /root/google_examples/bin/
RUN cp /root/benchmark/README.md /root/google_examples/

RUN rm -rf /root/googletest/ /root/benchmark/

ADD ./test /root/test
WORKDIR /root/test
RUN make

ADD ./README.md /root
WORKDIR /root

