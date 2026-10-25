FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Seoul

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash-completion ca-certificates curl git less nano procps sudo tree tzdata vim-tiny \
 && ln -fs "/usr/share/zoneinfo/$TZ" /etc/localtime \
 && rm -rf /var/lib/apt/lists/*

RUN (userdel -r ubuntu 2>/dev/null || true) \
 && useradd -m -s /bin/bash learner \
 && echo 'learner ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/learner \
 && chmod 440 /etc/sudoers.d/learner

# 초보자가 vim에 갇히지 않도록 기본 편집기는 nano
RUN git config --system user.name "Learner" \
 && git config --system user.email "learner@lab.local" \
 && git config --system init.defaultBranch main \
 && git config --system core.editor nano \
 && git config --system color.ui auto \
 && git config --system advice.detachedHead false \
 && git config --system --add safe.directory '*'

WORKDIR /home/learner
