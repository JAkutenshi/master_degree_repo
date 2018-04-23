FROM jakutenshi/ubuntu-dev:latest

RUN apt-get update           \
    && apt-get install -y    \
    zip                      \
    unzip                    \
    subversion               \
    libxml2-dev              \
    libssl-dev               \
    libsqlite3-dev           \
    libboost-all-dev         \
    libogre-1.9-dev          \
    libsvn-dev               \
    libopencv-core-dev       \
    libopencv-flann-dev      \
    libopencv-ml-dev         \
    libopencv-calib3d-dev    \
    libopencv-dev            \
    libopencv-imgproc-dev    \
    libopencv-gpu-dev        \
    libopencv-objdetect-dev  \
    libopencv-contrib-dev    \
    libopencv-features2d-dev \
    libopencv-legacy-dev     \
    libopencv-highgui-dev \
    libopencv-video-dev   \
    libcvaux-dev          \
    libcv-dev             \
    binutils-dev          \
    libiberty-dev         \
# Qt4
    qt4-dev-tools         \
    libqt4-dev            \
    libqt4-opengl-dev     \
    libqtwebkit-dev       \
    libqwt-dev            \
# Qt5
    qt5-default           \
    libqwt-qt5-dev        \
    libqt5webkit5-dev     \
    libqwtmathml-qt5-dev  \
    libqt5opengl5-dev     \
    libqt5svg5-dev        \
    qt*5-dev              \
    qttools5-dev-tools

WORKDIR /root/
ADD mira-installer-no-interact.sh /root/
RUN chmod +x /root/mira-installer-no-interact.sh \
    && /root/mira-installer-no-interact.sh
RUN echo "export MIRA_PATH=/my/path/to/mira" >> .bashrc                            \
 && echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/my/path/to/mira/lib" >> .bashrc \
 && echo "export PATH=$PATH:/my/path/to/mira/bin" >> .bashrc
