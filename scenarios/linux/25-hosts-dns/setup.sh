#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
old="10.$(rand_int 20 200).$(rand_int 0 255).$(rand_int 2 250)"
secret_set old "$old"
mkdir -p /srv/api && echo ok > /srv/api/health
busybox httpd -p 127.0.0.1:8000 -h /srv/api >/dev/null 2>&1 < /dev/null
cp /etc/hosts /opt/cmdlab/secret/hosts.orig
{
  echo
  echo "# 사내 서비스 (2025-03 등록, 구 IDC)"
  echo "$old  api.internal"
  echo "$old  admin.internal"
} >> /etc/hosts
grep -v -e 'api.internal' -e 'admin.internal' -e '^# 사내' /etc/hosts | sed '/^$/d' > /opt/cmdlab/secret/hosts.keep
