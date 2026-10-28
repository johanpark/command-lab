FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Seoul \
    EDITOR=nano

# docker.io: 컨테이너 안에서 돌릴 Docker 엔진과 CLI
# busybox-static: 인터넷 없이 실습용 이미지를 만들기 위한 정적 바이너리
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash-completion busybox-static ca-certificates curl docker-buildx docker-compose-v2 docker.io \
      iproute2 jq less nano procps sudo tree tzdata \
 && ln -fs "/usr/share/zoneinfo/$TZ" /etc/localtime \
 && rm -rf /var/lib/apt/lists/*

RUN (userdel -r ubuntu 2>/dev/null || true) \
 && useradd -m -s /bin/bash -G docker learner \
 && echo 'learner ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/learner \
 && chmod 440 /etc/sudoers.d/learner

COPY lab-docker.sh /usr/local/lib/lab-docker.sh
COPY start-dockerd.sh /usr/local/bin/start-dockerd
RUN chmod +x /usr/local/bin/start-dockerd

WORKDIR /home/learner
