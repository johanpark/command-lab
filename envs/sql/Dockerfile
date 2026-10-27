FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Seoul \
    EDITOR=nano

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash-completion ca-certificates less nano procps sqlite3 sudo tree tzdata \
 && ln -fs "/usr/share/zoneinfo/$TZ" /etc/localtime \
 && rm -rf /var/lib/apt/lists/*

RUN (userdel -r ubuntu 2>/dev/null || true) \
 && useradd -m -s /bin/bash learner \
 && echo 'learner ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/learner \
 && chmod 440 /etc/sudoers.d/learner

# sqlite3 결과를 표(box) 모양으로 보기 좋게 (.sqliterc 는 실행할 때마다 안내 문구를 찍어서 별칭으로)
RUN echo "alias sqlite3='sqlite3 -box'" >> /home/learner/.bashrc

WORKDIR /home/learner
