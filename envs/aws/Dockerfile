FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Seoul \
    EDITOR=nano

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash-completion ca-certificates curl jq less nano procps python3 python3-venv sudo tree tzdata unzip vim-tiny \
 && ln -fs "/usr/share/zoneinfo/$TZ" /etc/localtime \
 && rm -rf /var/lib/apt/lists/*

# AWS CLI 와 moto(가짜 AWS 서버)를 각각의 가상환경에 (서로 다른 botocore 버전을 원할 수 있어서)
RUN python3 -m venv /opt/awscli && /opt/awscli/bin/pip install --no-cache-dir -q 'awscli==1.42.*' \
 && python3 -m venv /opt/moto && /opt/moto/bin/pip install --no-cache-dir -q 'moto[server]==5.0.28' \
 && ln -s /opt/awscli/bin/aws /usr/local/bin/aws \
 && ln -s /opt/awscli/bin/aws_completer /usr/local/bin/aws_completer \
 && echo 'SSL_COMMON_NAMES.clear()  # cmdlab: sqs 등도 AWS_ENDPOINT_URL(가짜 AWS)을 따르게' \
      >> "$(/opt/awscli/bin/python -c 'import awscli.customizations.overridesslcommonname as m; print(m.__file__)')"
# ↑ AWS CLI v1 은 sqs·emr 같은 일부 서비스에서 AWS_ENDPOINT_URL 을 무시하고 옛 공식 주소로 고정한다

# 실습용 가짜 AWS 계정: 모든 aws 명령이 컨테이너 안의 moto 로 간다
ENV AWS_ENDPOINT_URL=http://127.0.0.1:5000 \
    AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \
    AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
    AWS_DEFAULT_REGION=ap-northeast-2 \
    AWS_PAGER=""

RUN (userdel -r ubuntu 2>/dev/null || true) \
 && useradd -m -s /bin/bash learner \
 && echo 'learner ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/learner \
 && chmod 440 /etc/sudoers.d/learner \
 && echo 'complete -C aws_completer aws' > /etc/profile.d/aws-completion.sh \
 && ln -sf /usr/bin/vim.tiny /usr/local/bin/vim \
 && printf '%s\n' 'set nocompatible' 'set backspace=indent,eol,start' 'set ruler' 'set showmode' >> /etc/vim/vimrc.tiny \
 && printf '%s\n' 'set nocompatible' 'set backspace=indent,eol,start' 'set ruler' 'set showmode' >> /etc/vim/vimrc

COPY patch-moto.py /tmp/patch-moto.py
RUN /opt/moto/bin/python /tmp/patch-moto.py && rm /tmp/patch-moto.py

COPY lab-aws.sh /usr/local/lib/lab-aws.sh
COPY start-moto.sh /usr/local/bin/start-moto
RUN chmod +x /usr/local/bin/start-moto

# 위 보정들이 실제로 동작하는지 확인 (moto 를 올렸다가 하나라도 깨지면 빌드 실패)
COPY patch-check.sh /tmp/patch-check.sh
RUN bash /tmp/patch-check.sh && rm /tmp/patch-check.sh

WORKDIR /home/learner
