FROM andrewosh/binder-base

USER root

RUN apt-get update && \
    apt-get -y install screen git curl gcc make g++ python-dev unzip \
           default-jre pkg-config libncurses5-dev r-base-core \
           r-cran-gplots python-matplotlib sysstat python-virtualenv \
           python-setuptools cmake ncbi-blast+ fastqc

USER main

RUN cd /home/main && git clone https://github.com/voutcn/megahit.git && cd megahit \
    && make

RUN cd /home/main && \
    git clone https://github.com/ablab/quast.git -b release_4.2

ENV PATH=$PATH:/home/main/megahit:/home/main/quast
