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

#-- Install the ling110 tool
COPY tools/ling110 /usr/local/bin
RUN chmod +x /usr/local/bin/ling110

RUN rm -rf /home/jovyan/work

#-- Scaffold the locations and starting content
USER $NB_USER

# introductory notebook file
RUN wget -q https://sjtodd.github.io/ling110/intro-notebook.ipynb -O $HOME/intro-notebook.ipynb

# assignment folders
RUN mkdir -p $HOME/assignments
RUN mkdir -p $HOME/.util

# Create .gitignore
RUN cat > $HOME/.gitignore <<EOF
**/__pycache__/*
**/.ipynb_checkpoints/*
**/.pytest_cache/*
**/core.*
EOF

RUN git config --global core.excludesFile $HOME/.gitignore

# Update Jupyterlab advanced settings files
RUN mkdir -p $HOME/.jupyter/lab/user-settings/@jupyterlab

RUN mkdir -p $HOME/.jupyter/lab/user-settings/@jupyterlab/docmanager-extension
RUN cat > $HOME/.jupyter/lab/user-settings/@jupyterlab/docmanager-extension/plugin.jupyterlab-settings <<EOF
{
    defaultViewers: {
        markdown: "Markdown Preview",
        json: "Editor"
    }
}
EOF

RUN mkdir -p $HOME/.jupyter/lab/user-settings/@jupyterlab/fileeditor-extension
RUN cat > $HOME/.jupyter/lab/user-settings/@jupyterlab/fileeditor-extension/plugin.jupyterlab-settings <<EOF
{
    "editorConfig": {
        "fontSize": 14,
        "lineNumbers": true,
        "codeFolding": true
    }
}
EOF

RUN mkdir -p $HOME/.jupyter/lab/user-settings/@jupyterlab/notebook-extension
RUN cat > $HOME/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings <<EOF
{
    "kernelShutdown": true,
    "codeCellConfig": {
        "lineNumbers": true
    },
    "showEditorForReadOnlyMarkdown": false
}
EOF

RUN mkdir -p $HOME/.jupyter/lab/user-settings/@jupyterlab/terminal-extension
RUN cat > $HOME/.jupyter/lab/user-settings/@jupyterlab/terminal-extension/plugin.jupyterlab-settings <<EOF
{
    "fontSize": 14,
    "shutdownOnClose": true
}
EOF

RUN mkdir -p $HOME/.jupyter/lab/user-settings/@jupyterlab/apputils-extension
RUN cat > $HOME/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/notification.jupyterlab-settings <<EOF
{
    "fetchNews": "false",
    "doNotDisturbMode": true
}
EOF

RUN gh auth setup-git --hostname github.com --force

RUN echo 'echo "Welcome to the course environment, please run \e[1mling110\e[0m in terminal to check your assignment status"' >> $HOME/.bashrc


# Set environment variables for SRILM
ENV LC_NUMERIC=C \
    PATH=$PATH:/usr/bin/srilm/bin:/usr/bin/srilm/bin/i686-m64

WORKDIR /home/jovyan
