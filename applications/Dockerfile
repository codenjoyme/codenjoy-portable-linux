FROM openjdk:11-jdk as java_workspace

USER root
ENV DEBIAN_FRONTEND noninteractive

ARG TIMEZONE=Europe/Kiev

ARG MAINTAINER_NAME=User
ARG MAINTAINER_EMAIL=user@email.com
LABEL maintainer.name="${MAINTAINER_NAME}"
LABEL maintainer.email="${MAINTAINER_EMAIL}"

RUN apt-get update \
 && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata

# -----------------------------------------------------------------------

FROM java-workspace as codenjoy_source

ENV DEBIAN_FRONTEND noninteractive

ARG GIT_REPO=https://github.com/codenjoyme/codenjoy.git
ARG REF=master

ARG MAINTAINER_NAME=User
ARG MAINTAINER_EMAIL=user@email.com
LABEL maintainer.name="${MAINTAINER_NAME}"
LABEL maintainer.email="${MAINTAINER_EMAIL}"

RUN apt-get update \
 && apt-get -y install -y git \
 && git config --global user.name "${MAINTAINER_NAME}" \
 && git config --global user.email "${MAINTAINER_EMAIL}" \
 && cd /tmp \
 && git clone --recursive ${GIT_REPO} codenjoy \
 && cd /tmp/codenjoy/CodingDojo \
 && git checkout ${REF}

# -----------------------------------------------------------------------
