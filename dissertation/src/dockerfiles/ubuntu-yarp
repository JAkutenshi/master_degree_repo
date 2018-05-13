FROM jakutenshi/ubuntu-dev:latest

RUN apt-get update &&          \
    apt-get install -y         \
    cmake-curses-gui           \
    libeigen3-dev              \
    libace-dev                 \
    libedit-dev                \
    qtbase5-dev                \
    qtdeclarative5-dev         \
    qtmultimedia5-dev          \
    qml-module-qtquick2        \
    qml-module-qtquick-window2 \
    qml-module-qtmultimedia    \
    qml-module-qtquick-dialogs \
    qml-module-qtquick-controls

ADD yarp.tar.gz /root/
WORKDIR /root/yarp/build/
RUN cmake -DCREATE_GUIS=ON -DCREATE_LIB_MATH=ON ..
RUN make && make install && ldconfig
