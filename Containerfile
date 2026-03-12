FROM ucsb/jupyter-base:latest

MAINTAINER LSIT Systems <lsitops@lsit.ucsb.edu>

USER root

RUN apt update && \
    apt install -y \
        git \
        wget \
        tcsh \
        gawk \
        tar \
        make && \
    apt-get clean

#-- Install SRILM
RUN mkdir /usr/bin/srilm
WORKDIR /usr/bin/srilm
RUN wget https://sjtodd.github.io/ling110/srilm-1.7.3.tar.gz && \
    tar xvf srilm-1.7.3.tar.gz && \
    sed -i '1i SRILM = /usr/bin/srilm' Makefile && \
    make MAKE_PIC=yes World && \
    make cleanest

#-- Install GitHub CLI
RUN (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

#-- Install additional packages
RUN pip install gensim \
    scikit-learn \
    pytest \
    PTable \
    nltk \
    arpa \
    morfessor \
    rich \
    click

#-- copy the course setup files
COPY dist/ /opt/ling110/
RUN chmod +x /opt/ling110/bin/*
RUN ln -s /opt/ling110/bin/ling110 /usr/local/bin/ling110

# Set environment variables for SRILM
ENV LC_NUMERIC=C \
    PATH=$PATH:/usr/bin/srilm/bin:/usr/bin/srilm/bin/i686-m64

WORKDIR /home/jovyan
