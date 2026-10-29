#!/bin/sh
# 컨테이너 안에서 가짜 AWS(moto) 서버를 띄운다. 상태는 메모리에만 있어서 실습마다 깨끗하게 시작한다
# AWS 관리형 IAM 정책(AdministratorAccess, ReadOnlyAccess 등)도 미리 넣어 둔다
MOTO_IAM_LOAD_MANAGED_POLICIES=true /opt/moto/bin/moto_server -H 127.0.0.1 -p 5000 > /var/log/moto.log 2>&1 &
exec sleep infinity
