FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Seoul \
    EDITOR=nano \
    PYTHONDONTWRITEBYTECODE=1

# Python 3 (+ openpyxl: 엑셀, pip·venv: 가상환경), Node.js, cron
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash-completion ca-certificates cron curl file jq less nano procps sudo tree tzdata unzip vim-tiny \
      python3 python3-openpyxl python3-pip python3-venv nodejs \
 && ln -fs "/usr/share/zoneinfo/$TZ" /etc/localtime \
 && rm -rf /var/lib/apt/lists/*

# 실습용 사용자: learner (sudo 가능)
RUN (userdel -r ubuntu 2>/dev/null || true) \
 && useradd -m -s /bin/bash learner \
 && echo 'learner ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/learner \
 && chmod 440 /etc/sudoers.d/learner

# vim-tiny 를 vim 이라는 이름으로도 쓰게 하고, vi 호환 모드를 꺼서 방향키·백스페이스가 정상 동작하게
RUN ln -sf /usr/bin/vim.tiny /usr/local/bin/vim \
 && printf '%s\n' 'set nocompatible' 'set backspace=indent,eol,start' 'set ruler' 'set showmode' >> /etc/vim/vimrc.tiny \
 && printf '%s\n' 'set nocompatible' 'set backspace=indent,eol,start' 'set ruler' 'set showmode' >> /etc/vim/vimrc

WORKDIR /home/learner
