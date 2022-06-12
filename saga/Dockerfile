FROM ubuntu:20.04
LABEL maintainer="Sudipta Basak<basaks@gmail.com>"
ENV REFRESHED_AT 2022-05-12

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update -qq
RUN apt-get install -y libgdal-dev libwxgtk3.0-gtk3-dev swig python-dev libproj-dev libvigraimpex-dev
RUN apt-get -y install saga

CMD ["/bin/bash"]