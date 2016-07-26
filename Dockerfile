FROM andrewosh/binder-base

USER root

RUN apt-get update && \
    apt-get -y install screen git curl gcc make g++ python-dev unzip \
           default-jre pkg-config libncurses5-dev r-base-core \
           r-cran-gplots python-matplotlib sysstat python-virtualenv \
           python-setuptools cmake

USER main

