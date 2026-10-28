FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Seoul \
    EDITOR=nano \
    PYTHONDONTWRITEBYTECODE=1

# Python 3 (+ openpyxl: 엑셀), Node.js, cron
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash-completion ca-certificates cron curl file jq less nano procps sudo tree tzdata unzip vim-tiny \
      python3 python3-openpyxl nodejs \
 && ln -fs "/usr/share/zoneinfo/$TZ" /etc/localtime \
 && rm -rf /var/lib/apt/lists/*

# 실습용 사용자: learner (sudo 가능)
RUN (userdel -r ubuntu 2>/dev/null || true) \
 && useradd -m -s /bin/bash learner \
 && echo 'learner ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/learner \
 && chmod 440 /etc/sudoers.d/learner

WORKDIR /home/learner
