# Dockerfile to build/generate web-site rear-user-guide
# Using MkDocs - https://www.mkdocs.org/ 
#
# To build the docker container:
# 
# docker build -t mkdocs .
# or use another user then the default 'gdha' (with another uid) use:
# docker build --build-arg local_user=gdha --build-arg local_id=1002 -t mkdocs .
#
# The first time run of the 'mkdocs' container:
# docker run -it -v /home/gdha/projects/rear/rear-user-guide:/home/gdha/web \
#                -v /home/gdha/.gitconfig:/home/gdha/.gitconfig -v /home/gdha/.ssh:/home/gdha/.ssh \
#                -v /home/gdha/.gnupg:/home/gdha/.gnupg --net=host mkdocs
# Rename the image of mkdocs:
# docker rename <strange name> rear-user-guide
# Afterwards we can just start the container as:
# docker start -i rear-user-guide


FROM ubuntu:24.04
ARG local_user=gdha
ARG local_id=1000
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY *requirements.txt ./
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    python3 \
    python3-setuptools \
    python3-pip \
    make \
    gcc \
    curl \
    ca-certificates \
    git \
    openssh-client \
    gnupg \
    locales \
    vim \
    build-essential \
    mkdocs \
    mkdocs-material \
    python3-markdown2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# remove gcc afterwards again
RUN apt autoremove \
    && apt-get -y remove gcc

# Ubuntu 24 internal user ubuntu also uses uid 1000, so we switch the name with ours
RUN echo "Setting home directory for local user ${local_user}" \
    && usermod -l ${local_user}  ubuntu \
    && groupmod  --new-name ${local_user} ubuntu \
    && mkdir -p /home/${local_user}/web/ \
    && chown -R ${local_user}:${local_user} /home/${local_user}/web

# Needed to make nerdtree plugin for vim work and git credential.helper
RUN locale-gen en_US.UTF-8 \
    && echo "export LC_CTYPE=en_US.UTF-8" >> /home/${local_user}/.bashrc \
    && echo "export LC_ALL=en_US.UTF-8" >> /home/${local_user}/.bashrc

WORKDIR /home/${local_user}/web
USER ${local_user}
