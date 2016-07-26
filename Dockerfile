FROM andrewosh/binder-base

USER root

RUN apt-get update && \
    apt-get -y install screen git curl gcc make g++ python-dev unzip \
           default-jre pkg-config libncurses5-dev r-base-core \
           r-cran-gplots python-matplotlib sysstat python-virtualenv \
           python-setuptools cmake ncbi-blast+

RUN cd /home && git clone https://github.com/voutcn/megahit.git && cd megahit \
    && make

RUN cd /home && \\
    git clone https://github.com/ablab/quast.git -b release_4.2 && \\
    cd quast && ./install.sh

ENV PATH=$PATH:/home/megahit:/home/quast

USER main

