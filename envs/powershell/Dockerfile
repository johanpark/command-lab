FROM ubuntu:24.04

ARG PWSH_VERSION=7.4.6

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Seoul \
    POWERSHELL_TELEMETRY_OPTOUT=1 \
    POWERSHELL_UPDATECHECK=Off

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl less libicu74 nano procps sudo tree tzdata \
 && ln -fs "/usr/share/zoneinfo/$TZ" /etc/localtime \
 && rm -rf /var/lib/apt/lists/*

# Microsoft 공식 릴리스(tar.gz)로 설치: x64(Intel/Windows PC)와 arm64(Apple Silicon) 모두 지원
RUN case "$(dpkg --print-architecture)" in \
      amd64) arch=x64 ;; \
      arm64) arch=arm64 ;; \
      *) echo "지원하지 않는 아키텍처" >&2; exit 1 ;; \
    esac \
 && curl -fsSL -o /tmp/pwsh.tgz \
      "https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-linux-${arch}.tar.gz" \
 && mkdir -p /opt/microsoft/powershell/7 \
 && tar -xzf /tmp/pwsh.tgz -C /opt/microsoft/powershell/7 \
 && chmod +x /opt/microsoft/powershell/7/pwsh \
 && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh \
 && rm /tmp/pwsh.tgz

RUN (userdel -r ubuntu 2>/dev/null || true) \
 && useradd -m -s /bin/bash learner \
 && echo 'learner ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/learner \
 && chmod 440 /etc/sudoers.d/learner

# 모든 사용자 공통 프로필: 실습 안내 문구 출력
COPY profile.ps1 /opt/microsoft/powershell/7/profile.ps1

WORKDIR /home/learner
