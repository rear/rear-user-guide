# Dockerfile to build/generate web-site rear-user-guide
# Using MkDocs - https://www.mkdocs.org/ 
#
# To build the docker container:
# docker build -t mkdocs .
# or use another user then the default 'gdha' use:
# docker build --build-arg local_user=gdha -t mkdocs .
#
# The first time run of the 'mkdocs' container:
# docker run -it -v /home/gdha/projects/rear/rear-user-guide:/home/gdha/rear-user-guide -v /home/gdha/.gitconfig:/home/gdha/.gitconfig -v /home/gdha/.ssh:/home/gdha/.ssh --net=host mkdocs
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
    git \
    openssh-client \
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
    && mkdir -p /home/${local_user}/rear-user-guide/ \
    && chown -R ${local_user}:${local_user} /home/${local_user}/rear-user-guide

# Needed to make nerdtree plugin for vim work and git credential.helper
RUN locale-gen en_US.UTF-8 && \
    echo "export LC_CTYPE=en_US.UTF-8" >> /home/${local_user}/.bashrc && \
    echo "export LC_ALL=en_US.UTF-8" >> /home/${local_user}/.bashrc

WORKDIR /home/${local_user}/rear-user-guide
USER ${local_user}
