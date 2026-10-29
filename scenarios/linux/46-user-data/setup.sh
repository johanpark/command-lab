#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
dbhost="prod-db-$(rand_pick a b c)$(rand_int 1 9).internal"
secret_set dbhost "$dbhost"
# 앱 릴리스 (busybox httpd 로 흉내)
R=$(mktemp -d); mkdir -p "$R/shop-2.4.0"/{bin,config,www}
cat > "$R/shop-2.4.0/bin/start.sh" <<'SH'
#!/bin/sh
# shop 앱 시작: 설정을 읽고 8080 에서 응답한다
cd "$(dirname "$0")/.."
. ./config/app.env
[ -n "${DB_HOST:-}" ] || { echo "start.sh: DB_HOST 가 비어 있어요" >&2; exit 1; }
[ "$(id -un)" != root ] || { echo "start.sh: root 로 실행하지 마세요" >&2; exit 1; }
echo ok > www/health
echo "db=$DB_HOST" > www/info
exec busybox httpd -p "$PORT" -h "$(pwd)/www"
SH
chmod 755 "$R/shop-2.4.0/bin/start.sh"
printf 'PORT=3000\nDB_HOST=\nLOG_LEVEL=info\n' > "$R/shop-2.4.0/config/app.env.example"
mkdir -p /var/cache/releases; tar czf /var/cache/releases/shop-2.4.0.tar.gz -C "$R" shop-2.4.0; rm -rf "$R"
# user-data 스크립트
mkdir -p /var/lib/cloud/instance/scripts
cat > /var/lib/cloud/instance/user-data.txt <<'UD'
#!/bin/bash
set -euxo pipefail
# shop 앱 설치 (런치 템플릿 v12)
id shop || useradd -r -m -d /opt/shop -s /usr/sbin/nologin shop
tar xzf /var/cache/releases/shop-2.4.0.tar.gz -C /opt/shop --strip-components=1
cp /opt/shop/config/app.env.example /opt/shop/config/app.env
sed -i "s/^PORT=.*/PORT=8080/" /opt/shop/config/app.env
sed -i "s/^DB_HOST=.*/DB_HOST=${DB_HOST}/" /opt/shop/config/app.env
chown -R shop:shop /opt/shop
sudo -u shop /opt/shop/bin/start.sh
UD
cp /var/lib/cloud/instance/user-data.txt /var/lib/cloud/instance/scripts/part-001
chmod 700 /var/lib/cloud/instance/scripts/part-001
# 실제로 부팅 때처럼 실행하고 출력을 로그로 (DB_HOST 에서 멈춘다)
pkill -f 'busybox httpd -p 8080' 2>/dev/null || true
userdel -r shop >/dev/null 2>&1 || true; rm -rf /opt/shop
{
  echo "Cloud-init v. 24.1.3 running 'modules:final' at $(date -u '+%a, %d %b %Y %H:%M:%S +0000'). Up 18.42 seconds."
  env -u DB_HOST bash /var/lib/cloud/instance/scripts/part-001 2>&1 || true
  echo "$(date -u '+%Y-%m-%d %H:%M:%S,%3N') - cc_scripts_user.py[WARNING]: Failed to run module scripts_user (scripts in /var/lib/cloud/instance/scripts)"
  echo "$(date -u '+%Y-%m-%d %H:%M:%S,%3N') - util.py[WARNING]: Running module scripts_user (<module 'cloudinit.config.cc_scripts_user'>) failed"
  echo "Cloud-init v. 24.1.3 finished at $(date -u '+%a, %d %b %Y %H:%M:%S +0000'). Datasource DataSourceEc2Local.  Up 24.07 seconds"
} > /var/log/cloud-init-output.log
chmod 640 /var/log/cloud-init-output.log
cat > "$H/runbook.md" <<MD
# shop 운영 문서

## 설정값 (prod)
| 이름 | 값 |
|---|---|
| DB_HOST | \`$dbhost\` |
| PORT | \`8080\` |

> 런치 템플릿 v12 에서 SSM 파라미터 연동을 빼면서 DB_HOST 를 넘기는 부분이 빠졌다는 제보가 있음 (확인 필요)
MD
give "$H/runbook.md"
