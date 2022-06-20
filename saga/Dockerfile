FROM ubuntu:20.04
LABEL maintainer="Sudipta Basak<basaks@gmail.com>"
ENV REFRESHED_AT 2022-05-12

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update -qq
RUN apt-get install -y libgdal-dev libwxgtk3.0-gtk3-dev swig python-dev libproj-dev libvigraimpex-dev
RUN apt-get install -y g++ cmake cmake-qt-gui make libtool git
RUN apt-get install -y ibwxgtk3.0-gtk3-dev libtiff5-dev libexpat1-dev wx-common libogdi-dev unixodbc-dev

RUN mkdir -p /home/devel \
    && cd /home/devel \
    && git clone https://github.com/saga-gis/saga-gis.git saga-gis-code \
    && cd /home/devel/saga-gis-code
RUN apt install -y python3-dev
RUN cd /home/devel/saga-gis-code \
    && mkdir -p build \
    && cd /home/devel/saga-gis-code/build \
    && cmake ../saga-gis -DCMAKE_BUILD_TYPE=RELEASE -DWITH_TRIANGLE=OFF -DWITH_SYSTEM_SVM=ON -DWITH_DEV_TOOLS=OFF \
    && cmake --build . --config Release \
    && cmake --install .

RUN apt-get -y install saga

CMD ["/bin/bash"]