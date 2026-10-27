FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Seoul \
    EDITOR=nano

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash-completion ca-certificates cron curl file gawk iproute2 iputils-ping jq less lsof \
      nano netcat-openbsd procps psmisc sudo tree tzdata unzip vim-tiny wget zip \
 && ln -fs "/usr/share/zoneinfo/$TZ" /etc/localtime \
 && rm -rf /var/lib/apt/lists/*

# 실습용 사용자: learner (sudo 가능)
RUN (userdel -r ubuntu 2>/dev/null || true) \
 && useradd -m -s /bin/bash learner \
 && echo 'learner ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/learner \
 && chmod 440 /etc/sudoers.d/learner

WORKDIR /home/learner
