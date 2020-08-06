# Dockerfile to build/generate web-site relax-and-recover.github.io
# Using MkDocs - https://www.mkdocs.org/ 
#
# To build the docker container:
# docker build -t mkdocs .
# or use another user then the default 'gdha' use:
# docker build --build-arg local_user=jane -t mkdocs .
#
# The first time run of the 'mkdocs' container:
# docker run -it -v /home/gdha/projects/rear/relax-and-recover.github.io:/home/gdha/relax-and-recover.github.io  --net=host mkdocs
# Afterwards we can just start the container as:
# docker start -i mkdocs


FROM ubuntu:18.04
ARG local_user=gdha
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    python3 \
    python3-distutils \
    make \
    gcc \
    curl \
    ca-certificates \
    locales \
    vim \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install pip and mkdocs
RUN curl -o /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py \ 
    && python3 /tmp/get-pip.py \
    && pip install --upgrade pip \
    && pip install mkdocs \
    && pip install mkdocs-ivory

RUN echo "Setting home directory for local user ${local_user}" \
    && useradd -u 1001 ${local_user} \
    && mkdir -p /home/${local_user}/relax-and-recover.github.io \
    && chown -R ${local_user}:${local_user} /home/${local_user}/relax-and-recover.github.io

# Needed to make nerdtree plugin for vim work
RUN locale-gen en_US.UTF-8 && \
    echo "export LC_CTYPE=en_US.UTF-8" >> /home/${local_user}/.bashrc && \
    echo "export LC_ALL=en_US.UTF-8" >> /home/${local_user}/.bashrc

WORKDIR /home/${local_user}/relax-and-recover.github.io
USER ${local_user}
